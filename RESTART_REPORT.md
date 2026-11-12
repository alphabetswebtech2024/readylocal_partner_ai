# ReadyLocal Partner: restart from your zip (2026-11-05)

Base: `~/Downloads/gotask_partner.zip` (byte-identical to the 23 Oct source, git tag `baseline-original`).
The 3–4 Nov payment changes were deliberately NOT carried over. Payment flow is the original, except the approved fee fix (A7) and rounding the amount to whole paise.

## API check results (live server, 2026-11-05)

Tested without logging in; nothing was created, sent or charged.
34 endpoints checked: 33 respond to the method the app uses; getRegistrationFees does not (A7). All need a login except the OTP pair (public by design; only an OPTIONS check, no OTP was sent) and acceptedJob (S1). An empty request with no login was sent to the POST endpoints; all but acceptedJob refused it at the login check, and acceptedJob returned a validation error.

| # | Finding | Evidence | Status |
|---|---------|----------|--------|
| A1 | Document upload sent no login token, so uploadToS3 refuses it | Live: POST with no token returns 401. Code had no Authorization header | **Fixed** |
| A2 | Accept, reject, complete, cancel, withdraw, start ride, reached, online/offline treated HTTP 200 + `Status: FAILED` as success, so a refused action looked successful | Live: acceptedJob returns HTTP 200 `{"Status":"FAILED","StatusCode":400}` | **Fixed** |
| A3 | Accept/reject/complete sent `jobId`; server error text asks for `JobId` | Live message: "partnerId and JobId are required" | **Fixed** (both sent) |
| A4 | Two upload paths used different field names and response names for one endpoint | Code | **Fixed** (other format tried only if refused; both responses read). Which format is right still needs a logged-in test |
| A5 | Welcome screen T&C and Privacy links opened a 404 (gotask.in) | Live: 404; readylocal.in pages 200 | **Fixed** |
| A6 | updateDeviceToken: payment screen sent `partnerId`, Home `partnerID` | Code | **Fixed** (both sent) |
| A7 | **getRegistrationFees: server has GET only, app sends POST, so it always fails and every partner is charged the ₹500 fallback** | Live: POST 403, GET 401 | **Fixed, approved by you 2026-11-05:** now GET with `partnerId`. Query name and response format are unconfirmed; if the response can't be read, or the fee is 0, the ₹500 fallback still applies |
| S1 | **acceptedJob answers with no login** (all others return 401). Anyone with IDs could call it | Live: 200 validation message | **Backend must fix** |
| G1 | Google Places, Geocoding, Directions keys respond correctly (Geocoding only on the Places key, the one the app uses for it) | Live | OK |

Not tested: any call needing a login (all response formats). Run `python3 tool/api_check.py <partner number>` yourself: it sends one OTP, then only reads. Write flows (accept, complete, payment, withdraw) need a staging server or a test partner plus a Razorpay test key.

## Other fixes
- **Startup:** a Firebase/storage failure or hang could leave a blank or stuck screen. Each step now has a time limit and the app still opens. Corrupt saved user no longer sticks the splash.
- **Crashes:** global error capture; no red error screen; photo pickers safe when leaving a screen; bad server error text can't crash the error handler.
- **Network:** read-only APIs retry twice with random delay; writes never auto-repeat. Fresh connections after Wi-Fi/mobile switch; Places calls have timeouts; technical error text never shown.
- **2 GB phones:** image memory limited to 48 MB; job photos decoded as thumbnails (a 12 MP photo was ~48 MB each); job photos sent at max 1600 px (**smaller photo on server, flagged for your OK**); lighter tap effect and map; no audio player leak.
- **Notifications:** job popup listener was only registered if permission was granted, and after the permission dialog. Now always. Token retried if offline at launch. Proper status-bar icon. New: Home notice when notifications are blocked, Profile > Job alert settings.
- **Status bar:** white icons on white screens fixed.

## Launch on Android and iPhone (added 2026-11-05)
- **Android:** added the missing app-visibility entries. On Android 11+ the Call, Map and Delete Account buttons could silently do nothing.
- **iOS:** permission text for camera, photos and location; minimum iOS 15.0 (Firebase requires it); Google Maps key setup; camera permission enabled in the Podfile; notification delegate; URL schemes for tel and UPI apps.
- **Still needed for iOS:** build in Xcode (not done here), enable Maps SDK for iOS on the Google key, APNs key in Firebase, Push capability in Apple Developer.

## Full walkthrough on a test emulator (2026-11-05)
Release build on an Android 15 emulator with about 2.5 GB RAM, using a temporary test copy that talks to a local fake server. Fake data follows the formats the app and customer app expect, so real server responses are still unconfirmed. Tested: login and OTP errors, registration for Home Services, document and job photo uploads, Pandit, Driver and Medical screens, Home, online/offline, job start to complete, job close with reason, Earnings, Withdraw, Add Bank, Profile, logout, Telugu, refused actions, offline start.

Bugs this found, all in the original zip and now fixed:
- **Setup lists could not draw names:** Home Services, Pandit and Medical lists read `Name`, but the data models kept only `name`. On a real phone the rows would fail. Models now keep the full server record.
- **Back to home returned to Job Progress:** the finished job stayed open and could be resubmitted. Job Progress now goes through the router.
- **Medical and Driver lost their module:** the router dropped it, so Medical asked for categories with an empty ID and Driver saved a blank one.
- **Black band behind the phone's navigation bar.**

Not fixed; owner decision:
- **Work Done feedback (changed with owner approval):** the screen required it but never sent it. `completedJob` now sends it as `reason`. The backend must confirm it stores this field.
- **Home Services and Pandit use hard-coded module IDs** in the app, not the selected module's ID, and Home Services ignores `hasCategory`. Passing them would add a Category step for modules that have it.
- **Address starts with ", "** when the house number is empty.
- **Terms page on readylocal.in contains placeholder text** ("Last updated: [DATE]", "Placeholder text"). Fix before store review.

Not tested: real server responses, real push and job popup on a device, Razorpay payment, iPhone, a physical 2 GB phone.

## Speed, already-registered message and comparison with the original (2026-11-05)
- **Original vs updated, same emulator and fake server:** login, job open, Start Ride, Reached, photo upload and Work Done sent the same requests in the same order with the same fields. The only difference is `completedJob`, which also sends `JobId` and `reason`. Original-app bugs confirmed by running it: Back to home returned to Job Progress, and sub category rows failed to draw.
- **Speed:** removed the full-screen blur from loaders; spinner appears only after 250 ms; job opening and the address screen no longer wait for a fresh GPS fix (recent position, or 3–4 s at most); Home no longer loads twice or blocks the screen on refresh; splash fetches status during the animation; address search waits for typing to pause.
- **Select Service:** the list no longer waits for the fee (fee waits 8 s at most on Next) and shows an error with Retry instead of a blank screen. Timeouts and 504 are no longer retried, and the connect timeout is 10 s.
- **Fixed my own mistake:** a theme setting made every popup title white on white.
- **Already registered:** Register plus an existing number shows a message after OTP, then continues to the account. Login, and Register with a new number, are unchanged. The server only identifies the partner after OTP; showing it earlier needs a backend check.

## Final end-to-end retest (2026-11-06)
Final code on an Android 15 emulator with a local fake server, English and Telugu: first open, phone and OTP errors, already-registered message, personal details, location search, Select Service with a stuck fee request, Home Services, Driver, Pandit and Medical setup through to documents, document uploads, activation fee screen, Home, online/offline, refused action, job summary, Call, Map, Start Ride, Reached, Work Done, Close Job, Back to home, Earnings, Withdraw, Add Bank, Profile, web pages, language change, logout, server unavailable.

More bugs found and fixed:
- **Driver setup (original bug):** service types could not be selected, because `firstWhere` with an entity `orElse` threw a TypeError on the model list. Driver registration could not finish.
- **Keyboard after Gender (my regression):** the keyboard reopened over the form. Gender no longer takes focus.

Not tested: real server responses, real push alerts and the job popup from a push, Razorpay checkout and after-payment screens, physical phones, iPhone. Performance was not measured on a real 2 GB phone.

## Design
Logo's exact colours (#344A84, #C93438; before they were close, not exact). One gradient header on every screen; white fields and dropdowns; filled tabs; gradient hero cards; old orange badges and old icons removed; Welcome rebuilt; animated logo splash (1.8 s, was a fixed 3 s) with native launch screen matched so nothing jumps.

## Telugu
Language switch on Welcome and Login (same setting as Profile). All 32 screens rendered in Telugu and reviewed. Fixed: Payment Failed text, job progress dropdown font, rates, module names, gender, languages. Server-provided text (service names, server error messages) stays as sent unless the backend sends Telugu.

## Workflow comparison with the original
Same API endpoints, same routes. Navigation calls in screens are the same, plus one new fallback: splash goes to Welcome if routing fails. Payload changes: A1, A3, A4, A6, smaller job photos, and the fee request is now GET (A7).

## Results
`flutter analyze`: 0 errors. `flutter test test`: 49 pass (4 consecutive runs). Screens: 32 × English + Telugu with no overflow.

**Activation fee, still to confirm:** run `tool/api_check.py` and check the printed fee. Partners who already passed Select Service keep their saved ₹500 until they select a service again (same saved-value behaviour as before).

**NOT verified:** no Android SDK or Xcode on this Mac, so no build was made and nothing has run on a phone. Closed-app notifications, real performance on a 2 GB phone, and logged-in flows are untested.

## What the app cannot promise alone
- "Never crash / never fail": risk is reduced; no app can guarantee it. Crashlytics will show what remains.
- Closed-app alerts need the backend to send HIGH priority (PUSH_NOTIFICATIONS.md), an APNs key for iPhone, and phone battery settings. Force-stopped apps get nothing until reopened (Android rule).
- 1000 people at once: that load lands on the AWS backend. The app now avoids retry storms, but only a load test on staging can prove capacity.
- Animation during install is not possible: Android and the Play Store control that screen.

## 2026-11-06: Select Service and registration fixed against the live server

**Cause.** The 23 Oct code read every catalogue list from `Data` and sent `moduleID`/`categoryId`. The live server replies in `modules`, `categories`, `subCategories`, `ServiceTypes`, `Services`, `data`, and needs `ModuleID`, `CategoryID`, `SubCategoryID`. The earlier fake server used the same wrong format, so the earlier passes for these screens were not valid. The September source was used as the reference.

**Fixed.** Select Service; categories, sub categories, service types; Personal Care, Pandit, Medical and Driver lists; module passed to Select Categories and Pandit; activation payment save (`saveTransaction_pat` fields); add bank, bank list, withdraw and transaction details; extra field names on accept, start, reached and complete job (existing names kept).

**Fee.** Per service from `RegistrationFees`. 0 means waived; no row or a failed request means ₹500. All live amounts were 0 on 2026-11-06, so partners currently register free.

**Tested.** 78 automated tests including `test/live_format_test.dart`. Read-only live check of the catalogue with the fixed request names, all 8 services. Emulator (2 GB) against a fake server rebuilt from live formats: Select Service list, Home Services, Personal Care, Physiotherapy, Pandit and Driver lists, and Home Services through upload, free submit and Home.

**Not tested.** Select Service inside the APK on the live server, Nursing, Caregiver and Learning screens, a real Razorpay payment, a real bank add or withdrawal, real push, physical phones, iPhone. Bank, withdraw and job requests follow the September source; live replies to those writes are unconfirmed.

**Live data to check.** Learning Services > Tuition has no service types, and the screen requires one, so that registration cannot finish. Personal Driver has no categories (not needed by its screen). The free route shows "We have received your payment", which is the original text.

## 2026-11-06: Checked against the original code (build 7)

Every screen's fields, every request's fields and navigation were compared with the September source and the 23 Oct baseline.

**Fixed.** My Telugu work had turned the saved profile field `Services` into translated text on Pandit and Medical, so in Telugu the server would get a Telugu field name. Online/offline now sends `ACTIVE`/`INACTIVE` as in September (23 Oct sent `ONLINE`/`OFFLINE`). Location is sent only while online, as in September. Complete job adds `isCustomerAvailable: Yes`; cancel adds `isCustomerAvailable: No` and `Review`.

**Same as the original.** Personal information and profile save fields, driver saved profile, navigation apart from the agreed fixes.

**Kept on purpose, differs from September.** Razorpay `external.wallets` empty setting not sent (as in 23 Oct); job routes go Home if opened without data; splash goes to Intro if routing fails; "already registered" message.

**Not confirmed live.** No write call was run on the live server, including `ACTIVE`/`INACTIVE`. Test online/offline with a real job on a real phone.

## 2026-11-06: Branded images and verification check (build 8)

Cartoon `successImage` and the off-brand `home_banner` (GoTask shirt, green button) replaced by `partner_welcome.webp` and `job_banner.webp`, made from the user's reference image. Used on Welcome, Request Accepted, Work Status Success, Job Overview fallback and job popup fallback. Payment failed stays a plain icon.

Admin verification waiting screen: not found in the 12 Oct, 15 Oct, 20 Sept or 23 Oct sources, or in the Sept old debug APK text search. All go from Request Accepted to Home. Not built: the server field that says "admin approved" is not known. Gating on the wrong field could lock out every partner.

## 2026-11-06: Admin verification screens (build 9)

No old source has an approval field, so this is a new server contract. `getPartnerDetails` Data needs `verificationStatus` (PENDING, APPROVED, REJECTED) and `verificationReason`. A partner with no status goes Home as before, so existing partners are unaffected. Status is read at splash, after login and on Explore App. Resubmitting after rejection sends only `updateProfile_pat`, with no fee and no transaction; the server must set the status back to PENDING.

Also fixed: reopening the app after choosing a service but before documents crashed in the 23 Oct code (a String was cast to PartnerCategory). Document category follows the 15 Oct logic, so Nursing, Physiotherapy and Caregiver count as medical.

Tested on the emulator against a fake server only. The live server does not send these fields yet, so build 9 behaves as before on live.

## 2026-11-06: Approval block and speed (build 10)

Whoever registers on this device (reaches Request Accepted) waits until the server sends `verificationStatus: APPROVED`, even if the server sends no status yet. The Request Accepted button now says Continue. No status and no local registration still goes straight Home, so existing partners are unaffected. Gap until backend ships: logging in on another phone or after a reinstall has no local flag, so a new partner with no server status reaches Home.

Speed, 2 GB emulator with getPartnerDetails delayed 2.5 s (seen on live): numbers on Home at 8.2 s before, 5.2 s after. Home shows the last saved dashboard at once and refreshes; a known ready partner does not wait for the server at splash; Verified tick 5 s to 2 s. First open after install or login still waits for the server. Live getPartnerDetails took 2.5 s and some catalogue calls 3 s, which is backend.

## 2026-11-07: Full audit (FINAL APK, build 11)

**Fixed.** Token upload retried; pushes queued and de-duplicated (two together could leave a stuck loading dialog; a numeric RequestID threw); service lists cached 10 minutes (read-only lists only, never fees, payments or jobs); Telugu names from `mlName.te` plus a fixed list; "payment received" wording on waived fee; IFSC wording; whole Add Bank row tappable. Removed 7 unused widget files; 210 automatic lint fixes, with screen images byte-identical before and after.

**Differences from original kept on purpose.** See earlier sections: real API names and formats, per-service fee, ACTIVE/INACTIVE, verification block, already-registered message, safer routing, faster Home, Verified 2 s. No price calculation changed.

**Tests.** 89 logic tests. 33 screens rendered in English, Telugu and small phone. Emulator with fake server: login, online toggle, accept from popup, start, reached, complete, cancel, add bank, withdraw, earnings, profile, language, Telugu setup lists, registration and verification.

**Not tested.** Real backend writes, real Razorpay, real push, physical phones, iPhone, Nursing and Caregiver setup beyond their lists.

**Open questions.** Home shows Offline after each app restart while the server stays ACTIVE (same in September). Some server names have no Telugu (`mlName`) and stay English; dates and customer data stay as sent.
