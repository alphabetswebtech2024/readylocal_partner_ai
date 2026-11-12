# Real-time job alerts when the app is closed (2026-11-03)

**Problem:** partners only got job alerts while the app was open.

## Why it happened

| # | Cause | Fixed in app? |
|---|---|---|
| N1 | The background push handler only wrote a log line, so data-only job pushes were dropped when the app was in the background or closed | **Yes** |
| N2 | Tapping an alert that launched the app wasn't read (only Firebase's own taps were) | **Yes** |
| N3 | The push token reached the server only when Home loaded, and never after Firebase rotated it, so the server could hold a dead token | **Yes** |
| N4 | Background alerts had no job sound and used a normal-priority channel | **Yes** |
| N5 | iOS had no push entitlement and no `remote-notification` background mode, so a closed app could never be woken | **Yes** (needs an APNs key in Firebase; see below) |
| N6 | How the server sends the push (priority, payload type) | **Backend: see below** |
| N7 | Phone makers' battery savers (Xiaomi, Oppo, Vivo, Realme, OnePlus) block pushes for apps the user swiped away | Partner setting; see below |

## What changed in the app

- `lib/core/services/push_notification_service.dart`:
  - Background handler shows a **"New job request"** alert (service name • address) for data-only pushes, in the partner's saved language. Pushes with a `notification` block are left to the system, so nothing shows twice.
  - New Android channel **`job_requests`**: highest importance (heads-up, lock screen) with the job sound. It's also the manifest default channel.
  - Tapping an alert when the app was closed opens the app and the job popup.
  - The token is uploaded as soon as it's known and again on every refresh (same `updateDeviceToken` API Home already calls).
- `android/app/src/main/res/raw/notification_sound.mp3` (+ `keep.xml` so release builds keep it). Manifest default channel → `job_requests`.
- `ios/Runner/Runner.entitlements` (`aps-environment`), `UIBackgroundModes: remote-notification` in `Info.plist`, `CODE_SIGN_ENTITLEMENTS` on all Runner build configurations.
- Tests: `test/push_notifications_test.dart` (alert content, channel and sound, language, no duplicates, token upload).

## Backend: how to send a job push (N6)

Send to the partner's **device token** (from `updateDeviceToken`), not only the topic. Use the FCM HTTP v1 API:

```json
{
  "message": {
    "token": "<partner device token>",
    "data": {
      "RequestID": "<request id>",
      "ServiceID": "<service id>",
      "ServiceName": "AC Service & Repair",
      "CustomerName": "Sneha",
      "Address": "Madhapur, Hyderabad",
      "RequestDate": "2026-11-04",
      "Time": "04:00 PM - 05:00 PM",
      "Distance": "2.4"
    },
    "android": {
      "priority": "HIGH",
      "ttl": "120s"
    },
    "apns": {
      "headers": { "apns-priority": "10", "apns-push-type": "alert" },
      "payload": {
        "aps": {
          "alert": { "title": "New job request", "body": "AC Service & Repair • Madhapur, Hyderabad" },
          "sound": "default",
          "content-available": 1
        }
      }
    }
  }
}
```

Rules that matter:
1. **`android.priority: HIGH` is required.** Normal priority is delayed or dropped when the phone is idle (Doze).
2. **Android: keep it data-only** (no top-level `notification`). The app then shows the alert itself with the job sound and the popup data. If you do add `notification`, set `android.notification.channel_id: "job_requests"` and `sound: "notification_sound"`.
3. **iOS needs the `apns.alert` block.** iOS doesn't show data-only pushes when the app is closed.
4. **Keep all values as strings** in `data` (FCM requirement). The app already reads these keys.
5. Use a short `ttl` (job requests expire), and treat `UNREGISTERED` responses as "delete this token".

### Firebase console (once)
- Upload the **APNs authentication key** (Apple Developer → Keys) under Project settings › Cloud Messaging › Apple app configuration. Without it, iOS gets nothing.
- In the Apple Developer portal, enable **Push Notifications** for `com.readylocal.partner` and regenerate the provisioning profiles.

## Partner phone settings (N7)

The app can't override these. Put them in partner onboarding or support:
- **Notifications:** allowed for ReadyLocal Partner (Android 13+ asks on first launch).
- **Battery:** set ReadyLocal Partner to *No restrictions / Don't optimise*.
- **Xiaomi / Redmi / POCO:** Settings › Apps › ReadyLocal Partner › *Autostart* on; Battery saver › *No restrictions*.
- **Oppo / Realme / Vivo:** *Allow auto-launch* and *Allow background activity*.
- Don't swipe the app away with "force stop"; that blocks pushes until it's opened again.

## Verification

- **Automated:** handler shows the right alert on the right channel, in the right language; no duplicates; token upload. **PASS** (36 tests total).
- **Real device, app closed, Android and iOS:** **NOT VERIFIED** (no device or build tools on this Mac). Test with the payload above from the Firebase console or the backend, on one Xiaomi/Oppo phone and one iPhone.

## Audit 2026-11-07

Added: token upload retries (5 s, 15 s, 45 s, 2 min) and tries again on app resume, network return and login; pushes handled one at a time, the same job never shown twice.

Simulated on a 2 GB emulator by delivering pushes to the app's Firebase receiver: app open, in background and process killed on the test build (killed also in Telugu), and in the background on the release build. Alert at importance 5 on `job_requests`; tap opens the job popup.

Not tested: a real push from the live backend, `notification`-type pushes, Doze, phone-maker battery savers, iPhone. Backend must send data pushes with `android.priority: HIGH`, to the device token.

## Continuous ring (2026-11-07, build 12)

Data pushes: Android's insistent flag repeats the channel sound until the alert is opened or dismissed, and `timeoutAfter` removes it when the 45-second job window ends. App open: the job popup loops the sound at ringtone volume, stops when the partner starts to answer or the popup closes, and resumes if they go back to job details. Silent mode is respected.

A push with a `notification` block is shown by Android itself and rings once only. The backend must send job pushes as data-only for the continuous ring. iPhone cannot do this without Apple's special permission.

## Ring until someone accepts (2026-11-08, build 14)

Owner's rule: like Swiggy/Zomato, a new job keeps ringing on every notified partner's
phone until one partner accepts it. The app now rings (and keeps the job popup open)
for up to 10 minutes (`kJobRequestWindowSeconds = 600` in `lib/core/services/job_closed.dart`,
was 45 s in the 6 Nov app). It stops earlier when the partner answers, or when the
server sends the "job closed" push below.

### Backend must do (otherwise other partners keep ringing for 10 minutes)

1. Keep the job open to every notified partner until one accepts (an accept after
   45 seconds must still succeed).
2. When a partner accepts, or the customer cancels, send this **data-only, high-priority**
   push to every other partner who got the job:

```json
{
  "message": {
    "token": "<partner device token>",
    "android": { "priority": "HIGH", "ttl": "600s" },
    "data": { "type": "JOB_CLOSED", "RequestID": "<same RequestID as the job push>", "reason": "ACCEPTED_BY_OTHER" }
  }
}
```

`reason` can be `ACCEPTED_BY_OTHER` or `CANCELLED`. Also accepted as `type`: JOB_TAKEN,
JOB_ACCEPTED_BY_OTHER, JOB_CANCELLED, REQUEST_CANCELLED, JOB_EXPIRED.
3. Job pushes themselves: data-only, priority HIGH, `ttl` 600s (no `notification` block,
   or the phone rings once and stops).

Tested on a 2 GB emulator with the app swiped away: alert in about 1 s, still ringing
at 15 s, ring limit 9 min 59 s, removed by the JOB_CLOSED push. A force-stopped app
receives nothing (Android rule, same for every app); the setup guide tells partners
not to force stop.

## Job alert setup guide (2026-11-08)

Profile > "Job alert setup", a Home banner when something is missing, and opens by
itself once. Steps with a button that opens the exact phone page: notifications,
"New job requests" sound, Battery > Unrestricted, Autostart (Xiaomi, Oppo, Realme,
Vivo, iQOO, Huawei, Honor, OnePlus, Asus), pop-up + lock screen (Xiaomi). Plus
"Play a test alert". Native code: `MainActivity.kt` (channel
`com.readylocal.partner/alert_setup`). No restricted Play permission is used.
