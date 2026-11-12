# Partner app: 6 Nov original vs our build 12 (7 Nov)

Checked 2026-11-08. Reference: `~/Downloads/gotask_partner-06-NOV-2026.zip`.
Method: every logic change the developer made between the September source and 6 Nov
(formatting, comments and translation wrappers ignored), then checked in our tree, plus
request bodies for every API, app-start routing, payment options and Android config.

## Different from 6 Nov (to fix)

| # | Area | 6 Nov original | Our build 12 |
|---|------|----------------|--------------|
| 1 | Select Your Service | Learning Services (code `LS`) hidden | Still shown |
| 2 | Physiotherapy / Nursing / Caregiver | No duration/rate section; always sends Hourly, Days, 24 hours at price 0 | Rate popup; Next blocked without a rate |
| 3 | After documents | Request Accepted > Explore App > Home | Goes to "Details submitted" waiting screen, stuck (no server status) |
| 4 | Online/Offline toggle (`partnerOnOrOff`) | `ONLINE` / `OFFLINE` | `ACTIVE` / `INACTIVE` (my 6 Nov change from the September code) |
| 5 | Location (`sendLocationData`) | Sent on every Home open and every toggle, status ONLINE or OFFLINE | Sent only while online |
| 6 | Job photos (Job Progress) | Camera only | Camera and gallery |
| 7 | Language | English + Tamil | English + Telugu (needs your decision) |
| 8 | Reopening app mid-registration | Back button returns to earlier steps (Personal Info > Select Service > Documents > Fee) | Back button closes the app (inherited from 23 Oct code) |
| 9 | Version | 1.0.5+8 | 1.0.2+12. Must be higher than the Play Store version, e.g. 1.0.6+13 |

## In ours, not in 6 Nov (approved earlier, kept)

- Continuous job ring (45 s) and repeat popup.
- Work Done feedback sent as `reason` on completedJob.
- Extra duplicate field spellings (`JobId` + `jobId`, `ServiceID` + `serviceId`, `WorkPic` + `WorkPics`). The server ignores unknown fields; the 6 Nov fields are all present.
- 6 Nov shows a green "Location data is successfully sync." message on every Home open. Ours does not; it looks like a debug message.

## Same as 6 Nov (checked)

- Server URL (prod), live Razorpay key, login token on every request except OTP.
- Registration fee per service from server; ₹0 or medical = Submit with no payment; free transaction saved.
- Medical Experience Certificate document.
- Razorpay: UPI and card only, amount in paise.
- 45-second job timer and expiry on popup and Job Overview.
- Request bodies: accept, reject, start, reached, live location, cancel, complete, withdraw, request details.
- Read-only My Profile, Delete Account link, Notification bell removed from Home.
- App-start routing order (personal info > home > fee > documents > select service).
- App ID `com.readylocal.partner`, SDK levels, permissions, Firebase file, release signing setup (`key.properties` with your Play upload key is not in either zip).

## Not testable here

Real server write calls, real pushes, Razorpay payment, physical phones, iOS build.

## Status 2026-11-08 (test build 13, version kept at 1.0.2+12)

Done as per 6 Nov: items 1, 2, 3, 4, 5, 6, 8. Kept ours: item 7 (Telugu), item 9 (version).
Also: job photos 1280 px / quality 70 (was 1600 / 75); photo uploads retry twice automatically on a dropped connection.
Tests: 89 pass, including test/original_6nov_test.dart and test/original_6nov_flow_test.dart.

## Re-verification 2026-11-08 (build 14)

- APIs: every endpoint the 6 Nov app calls is called by ours; request fields compared for all
  of them. Same, or ours sends the same fields plus duplicate spellings (JobId/jobId etc.).
- Screens and navigation: every 6 Nov screen-to-screen step exists in ours.
- Fixed in this pass: Personal Information "Next" no longer calls updateProfile_pat; like
  6 Nov it saves on the phone and the server gets the details with the documents.
- Deliberate differences (owner's requests): Telugu instead of Tamil; job rings up to
  10 minutes until taken (6 Nov: 45 s); job alert setup guide; job photos 1280 px with
  upload retries; Home keeps the partner signed in when the network drops (6 Nov logged
  out on any error, including no signal). A server refusal still logs out.

## Tester issues 2026-11-08 (build 15)

1. Pay ₹500 after reopening: our build silently used the ₹500 fallback when the fee request
   failed and asked for it with an extra `partnerId`. Now exactly as 6 Nov: plain GET; a failed
   or non-SUCCESS fee reply shows "Could not load the registration fee" with Retry on Select
   Service, and no fee is saved. A service with no fee row is still ₹500 (6 Nov rule).
2. Delete Account opens in the in-app web page (About, Terms, Privacy already did).

Re-check found and fixed (now as 6 Nov): free registration sends `skills` = empty list when a
service was chosen on this pass; saves the partner locally once documents are accepted; stores
`TransactionID = FREE_REGISTRATION`; opens Payment Failed if only the ₹0 record fails.
No 1000-registration rule exists in the 6 Nov app code; the fee comes from the server.

## Bug list 2026-11-09 (build 16)

1. Profile web pages: About, Terms, Privacy and Delete Account all open and load inside the app
   (checked on the emulator with build 15+). Before build 15, Delete Account opened the browser.
2. Withdraw, now as 6 Nov: request carries only the 6 Nov fields (removed extra `Amount`, `Notes`,
   `BankDetail`); a server refusal shows the server's own message; Earnings with no data shows ₹0
   instead of an error. Not tested against the live server (needs a partner login).
