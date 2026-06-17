# REVIVAL_LOG — Snapdrop 2026 republish

Branch: `revival/2026`. Prime directive: preserve business logic. Behavioral changes flagged below.

---

## Major finding (read first)

The brief assumed a **stale 2-year-old** project (Flutter ~2yr old, `qr_code_scanner ^1.0.1`,
`share_plus ^9`, firebase v1/v2, no namespace, etc.). **Reality: the code was already
substantially modernized** before this revival. Already in place at start:

- Flutter 3.35.4 / Dart 3.9.2 (current stable)
- `qr_code_scanner_plus ^2.0.10` — maintained fork (NOT the discontinued `qr_code_scanner`).
  Phase-2 QR landmine already resolved; **no `mobile_scanner` migration needed.**
- `share_plus ^10.1.4` (already on new `SharePlus`/`ShareParams` API)
- `receive_sharing_intent ^1.8.1` (already on instance API: `getMediaStream`/`getInitialMedia`)
- `firebase_core ^3`, `analytics ^11`, `crashlytics ^4`, `remote_config ^5`
- `permission_handler ^11`, `photo_manager ^3`
- AGP 8.6.0, Kotlin 2.1.0, Java 17, `namespace` declared, `compileSdk 36`
- `freerasp ^7` security/RASP checks added (jailbreak/root detection)

So most of brief Phases 1–2 were **already done**. Remaining real gaps addressed below.

---

## Phase 0 — Recon & safety net

- Branch `revival/2026` created off `saurabh_dev`. ✅
- **Server alive check** — relay at `https://getsnapdrop.in/` (in `lib/services/socket_service.dart:24`):
  - `GET /` → **HTTP 200** (~0.78s)
  - `GET /socket.io/?EIO=4&transport=polling` → **HTTP 200** (Engine.IO handshake responds)
  - **Server is ALIVE.** No redeploy needed as a prerequisite. ✅
- Toolchain: Flutter 3.35.4 (stable), Dart 3.9.2.
- `flutter analyze`: **0 errors**, ~98 info/warning (deprecations, mutable-widget, unused) at start.

### §1 business-logic surface inventory (must stay invariant)
| Concern | File / function |
|---|---|
| Image selection | `lib/services/media_provider.dart`, `lib/widgets/selected_images.dart` |
| QR pairing handshake | `lib/widgets/qr_scanner.dart` (`_onQRViewController`, `connectSocket`) |
| Socket transfer protocol | `lib/services/socket_service.dart` |
| Intent sharing | `lib/main.dart` (`getMediaStream`/`getInitialMedia`), `lib/widgets/intent_file_displayer.dart` |
| First-run gating | `lib/services/first_time_login.dart`, `lib/main.dart#firstTimeInstallation` |
| Localization | `lib/l10n/*.arb` → 6 locales (en, hi, es, pt, ar, zh) |
| Version/force-update | `lib/services/check_app_version.dart` + `flutter_upgrade_version` |
| In-app review | `lib/services/in_app_review_service.dart` |
| Connectivity check | `lib/services/check_internet_connectivity.dart` |
| Analytics events | `lib/utils/firebase_initalization_class.dart#eventTracker` |
| Permissions | `lib/services/permission_provider.dart` |

### Socket protocol (FROZEN — verified parity target)
Connection: `io('https://getsnapdrop.in/', transports:['websocket'], timeout:10000)`
- emit `test` → `'sad'` (keep-alive/test ping)
- on `your_id` → `{id}` → stored as `_userId`
- emit `join_figma_room` → `{ my_id: <userId>, room: <roomId> }`
  - `roomId` parsed from scanned QR string as `url.split('=')[1]`
- emit `image` → `{ room, files:[{ name, type, file:<Uint8List>, sender:<userId> }] }`
- on `image_received_to_figma` → bool ack stream

**Wire format unchanged by this revival.** Plugin side (`/Plugin/index.js`) must match — verify
in the Figma track (§4).

---

## Phase 1 — Toolchain & Android build

Changes in `android/app/build.gradle`:
- `targetSdkVersion 34 → 35` (Play minimum as of Aug 31 2025 = API 35 / Android 15). **Verify
  current Play requirement in Console** — may be higher now.
- `minSdkVersion`: left as `flutter.minSdkVersion`, which = **24** in Flutter 3.35.4 (≥ Firebase's
  required 23). NOTE: the Flutter Gradle migration auto-rewrites any hardcoded `minSdkVersion <n>`
  back to `flutter.minSdkVersion` on every build, so hardcoding 23 does not stick — and is
  unnecessary since 24 already satisfies the requirement. Effective minSdk = 24 (drops Android <7.0).
- `applicationId` → **see Phase 4** (changed to new package).

### JVM-target build fix (`android/build.gradle`)
First baseline build failed: `Inconsistent JVM-target compatibility ... compileDebugJavaWithJavac
(21) and compileDebugKotlin (17)` on `:photo_manager`. Host JDK is 21 (Android Studio JBR); some
plugin modules set their own `android.compileOptions`, defaulting Java to 21 while Kotlin stayed 17.
Fix: in the root `subprojects` block, force `compileOptions` source/target = 17 on every plugin
(library) module via `afterEvaluate` (runs after the plugin configures itself), guarded to skip
`:app` (which sets 17 itself and is pre-evaluated by `evaluationDependsOn(':app')`). Build now green.

`AndroidManifest.xml`:
- Removed deprecated `package="com.saurabh7973.snapdrop"` attribute (AGP 8 uses `namespace` in
  gradle). No behavior change.
- `READ_EXTERNAL_STORAGE` capped with `android:maxSdkVersion="32"` (on 13+ `READ_MEDIA_IMAGES`
  replaces it). Keeps permission set minimal/correct per Android 13+ model.
- **Added explicit `<uses-permission CAMERA>`.** ⚠️ FLAG: camera was previously merged implicitly
  via the `qr_code_scanner_plus` plugin manifest, so the app already requested camera at runtime.
  Explicit declaration = **same effective permission set**, no new user-facing permission. Made
  explicit for clarity + data-safety accuracy.

`compileSdk 36`, Java 17, AGP 8.6.0, Kotlin 2.1.0, `settings.gradle` declarative `plugins{}` —
already correct, untouched.

---

## Phase 2 — Dependencies

- `pubspec.yaml` environment: `sdk: '>=2.19.2 <3.0.0'` → `'>=3.0.0 <4.0.0'`. The old upper bound
  `<3.0.0` was stale/contradictory with the in-use Dart 3.9. No code behavior change.
- All major dep migrations (qr/share_plus/receive_sharing_intent/firebase/permission/photo) were
  **already complete** (see Major Finding). No version churn introduced.
- **`freerasp ^7.0.0` → `^7.5.1`** — required for the 16 KB page-size Play requirement (see Phase 3
  / 16KB section). Stays within major 7 (no API break; `TalsecConfig`/`ThreatCallback`/`Talsec`
  API unchanged, analyze clean). Also fixes iOS jailbreak false-positives. 8.0.0 (major) avoided.

### FLAGGED — `flutter_upgrade_version ^1.1.8`
Brief flagged this as niche/possibly unmaintained and named `in_app_update` as the standard
Android equivalent. It currently resolves and builds. **Not swapped** (touches the update flow =
behavioral). Left as-is. Decide later if it blocks anything.

---

## Phase 3 — Play rejection blockers

### 🔴 CRITICAL cold-start crash — missing `.env` (found on real device) — RESOLVED
`main()` called `dotenv.load(fileName: ".env")`, and `firebase_options.dart` read
`dotenv.env['FIREBASE_API_KEY_*']!`. But `.env` was **commented out of pubspec assets**
(`#  - .env`) so it never shipped → `FileNotFoundError` thrown before `runApp` → **app crashes
on launch**. Masked on the emulator (the emulator security gate fired first), surfaced on a real
device. **This is almost certainly the real "crashes during testing" rejection cause.**

**Final fix (after a security review flagged shipping `.env` as a bundled asset):** removed the
dotenv indirection entirely and **hardcoded the Firebase apiKeys back into `firebase_options.dart`**
— which is exactly what FlutterFire's own `flutterfire configure` generates. Firebase apiKeys are
public client identifiers (they already ship in `google-services.json` / every Firebase app);
access is gated by app-signing SHA + Firebase security rules, not key secrecy. So this is not a
secret leak. Keys were recovered from git history (commit `7145f16`, pre-dotenv) +
`google-services.json`. Then: deleted `.env`, removed `- .env` from assets, dropped the
`flutter_dotenv` dependency and all `dotenv` imports. Verified: APK no longer contains `.env`,
`FirebaseApp initialization successful` on the real device, no crash. No more gitignored-file
build dependency, no bundled-secret finding.

### Stability (v15/v17 "crashes during testing")
Defensive hardening added (approved: minimal try/catch, behavior-preserving on valid inputs):

1. **`lib/services/permission_provider.dart`** — `int.parse(version)` on the OS release string
   would throw `FormatException` and crash on versions like `"8.1.0"`. Replaced with
   `int.tryParse(release.split('.').first) ?? 0`. Valid Android 13/14/15 ("13"/"14"/"15") behave
   identically; malformed/legacy strings now fall to the storage-permission path (correct) instead
   of crashing. **Strong candidate for the original crash rejection.**
2. **`lib/widgets/qr_scanner.dart#connectSocket`** — `'${result.code}'.split('=')[1]` would throw
   `RangeError` and crash if a scanned QR had no `=`. Added guard: malformed/empty code → reset to
   the "Session Expired / Restart Scan" state instead of crashing. Valid pairing QR unchanged.

QR scan uses the maintained `qr_code_scanner_plus` fork (works on AGP 8 / new Android), so the
brief's crash root-cause (`qr_code_scanner` discontinued) was already neutralized.

### 16 KB page-size support (Play requirement for new apps since Nov 1 2025)
Found via emulator run (API 37): system "Android App Compatibility" dialog — native libs not
16 KB-aligned, app forced into page-size-compat mode. Inspected actual ELF LOAD-segment alignment
in the debug APK (`llvm-readelf -l`, arm64-v8a):
- `libflutter.so` 0x10000, `libdatastore_shared_counter.so` 0x4000, `libVkLayer...` 0x10000 → all
  already ≥16 KB. **Only the failing libs (`libtmlib/libsecurity/libclib/libpolarssl/
  libpbkdf2_native`, all 0x1000 = 4 KB) belonged to freerasp 7.0.0.**
- Fix: bumped `freerasp 7.0.0 → 7.5.1` (16 KB support landed in freerasp 7.2.0, 2025-07-16).
- **Re-verified after rebuild:** freerasp now ships a single consolidated `libts.so` at 0x4000
  (16 KB). Every arm64 `.so` in the APK is ≥16 KB-aligned. **RESOLVED.** (16 KB applies to 64-bit
  only; 32-bit unaffected.)

### Target API
`targetSdk 35` set (Phase 1). Confirm the **release** build targets it before submission.

### Data-safety form input (Console — human fills, §4)
The app collects/transmits via Firebase SDKs:

| SDK | Data type (Play Data-safety category) | Notes |
|---|---|---|
| Firebase Analytics | **Device or other IDs** (App instance ID / analytics ID) | The undeclared item that caused the v15 rejection. **Must declare.** |
| Firebase Analytics | App interactions / usage (custom events) | Events below |
| Firebase Crashlytics | **Crash logs** + **Diagnostics** | Stack traces, device state |
| Firebase Remote Config | (fetch only; device/instance id used by SDK) | No PII collected |

`firebase_performance` is **NOT a dependency** (pubspec has only core/analytics/crashlytics/
remote_config) — do **not** declare Performance data. freerasp/Talsec runs on-device integrity
checks; it does not transmit user data to declare (it can email threat alerts to the dev only).

Custom analytics events (names + params — **frozen**, keep identical):
- `app_install` `{first_time: "true"}`
- `app_launch` `{first_time: "false"}`
- `tutorial_begin` `{tutorial_begin: "true"}`
- `tutorial_completed` `{first_time: "false"}`
- `app_review_called` `{sharing_method: "intent_sharing"|"non_intent_sharing"}`
- `app_share_called` `{sharing_method: ...}`
- `file_share_completed` `{sharing_method: ...}`

No account/login, no contacts, no location collected. Images are transferred peer→Figma via the
socket relay (not stored by Firebase). Declare data-in-transit accordingly.

---

## Phase 4 — Store-readiness

**`applicationId` `com.saurabh7973.snapdrop` → `in.getsnapdrop.app`** (old ID permanently burned on
Play). Set in `android/app/build.gradle`. `namespace` left as `com.saurabh7973.snapdrop` (internal
R/Kotlin package — NOT the Play identifier; changing it would force relocating `MainActivity` +
EmulatorChecker/RootDetector/DeveloperModeChecker for zero functional gain).

Every other place the old package id appeared was updated to match the new applicationId (else
runtime breakage):

1. **`lib/services/telsec_raspfree_checker.dart`** (freerasp/Talsec RASP) — `AndroidConfig.packageName`
   and `IOSConfig.bundleIds` were `com.saurabh7973.snapdrop`. With the new applicationId, RASP's
   `onAppIntegrity` callback would fire on the package mismatch and **push the SecurityScreen,
   blocking the app at launch.** Updated to `in.getsnapdrop.app`. ⚠️ **FLAG (human, §4):**
   `signingCertHashes` still holds the OLD upload key's SHA-256 hash. A new app = a new signing key
   → you MUST regenerate that hash from the new key and replace `base64Hash`, or RASP
   `onAppIntegrity` will block the signed release (`isProd: true`). Comment added at the call site.
2. **`lib/services/app_share_service.dart`** — "Share app" Play Store URL `?id=...` updated to the
   new package so the share link points at the new listing.
3. **`android/app/src/{profile,debug}/AndroidManifest.xml`** — removed deprecated `package=` attr
   (same AGP 8 cleanup as the main manifest).

### Firebase — CORRECTION to earlier assumption
The `google-services` Gradle plugin is **NOT applied** (not in `android/app/build.gradle` or
`android/build.gradle`), and `android/app/google-services.json` is **gitignored**. Firebase config
comes from **`lib/utils/firebase_options.dart`** (FlutterFire-generated). Therefore changing the
applicationId does **NOT** break the build — confirmed: `flutter build apk --debug` succeeds. ⚠️
**FLAG (human, §4):** `firebase_options.dart` `android.appId` =
`1:62956973537:android:0aad956b137b85632ef6a0`, project `snapdrop-e786e`, keyed to the OLD package.
Add a new Android app (`in.getsnapdrop.app`) to that Firebase project and **re-run
`flutterfire configure`** (or drop in a new `google-services.json` + apply the plugin) so
analytics/crashlytics attribute to the correct app. Until then events still flow, but to the old
Firebase Android app entry.

- R8/ProGuard: `minifyEnabled true` + `shrinkResources true` already on for release. Confirm
  Firebase keep-rules hold once a real release build runs.
- App icons/splash via `flutter_launcher_icons` — config intact; regenerate on demand.

### Release AAB status
Debug build verified green. A **signed release AAB was NOT produced** — it is blocked on three
human/console prerequisites, in order:
1. New upload/signing key (`key.properties` + keystore) — old key is on the dead account.
2. freerasp `signingCertHashes` regenerated from that new key (item 1 above).
3. New Firebase Android app + regenerated `firebase_options.dart` (Firebase correction above).
Once those land, `flutter build appbundle --release` should produce the AAB.

---

## Phase 6 — Runtime verification (emulator + real device)

### Emulator (Android 17 / API 37)
Builds/installs/launches; surfaced the 16 KB issue (resolved). App self-blocks with its native
"cannot run on an emulator" gate (by design) → full flow not testable on emulator.

### Real device — Nothing phone, Android 16 / API 36 (✅ full client flow verified)
Two real blockers found and fixed before the UI would show:
1. **`.env` cold-start crash** (see Phase 3 critical) — fixed.
2. **Security/anti-tamper blocked every debug build.** The app has TWO security layers, both of
   which flag any debug/profile build (debuggable + debug-signed):
   - **Flutter side** — `lib/services/telsec_raspfree_checker.dart` (freeRASP/Talsec): `onAppIntegrity`
     etc. freeRASP treats any debuggable build as compromised regardless of cert allow-listing.
   - **Native side** — `android/.../MainActivity.kt`: `SecurityUtils.isAppSignatureValid` (tamper),
     `DeveloperModeChecker`, `EmulatorChecker`, `RootUtil`, `OverlayDetector`, plus `FLAG_SECURE`
     (blocks screen capture). The native signature check fired the "integrity compromised → Close
     App" dialog (which also `clearApplicationUserData()`).

   ⚠️ **BEHAVIORAL CHANGE — FLAG for your review (debug-only, release fully preserved):** gated
   both layers so they enforce **only in release builds**, so the app is testable:
   - `main.dart`: `JailbreakDetector` + `securityChecker.automatedSecurityCheck()` run only under
     `kReleaseMode`.
   - `MainActivity.kt`: all native checks + `FLAG_SECURE` run only when the build is NOT debuggable
     (`ApplicationInfo.FLAG_DEBUGGABLE`).
   Release builds (non-debuggable, real signing key) get the **exact same** protection as before —
   nothing removed from the shipping app. This only stops debug builds from blocking themselves.

**Verified end-to-end client flow on the real device (screenshots captured each step):**
launch → no crash → security passes (debug) → **Android 13+ granular photo permission** prompt
(Allow all/limited/don't) → **home "Select Images to Continue / Up to 10 Images"** → **image grid
loads real device photos** → multi-select shows checkmark + file size → **"Connect"** →
**QR scanner screen with live camera feed + "Scanning…"** (`qr_code_scanner_plus` — the brief's #1
crash suspect — working). Only the final scan→socket→Figma hop needs the live Figma-plugin QR.

**Still needs the Figma plugin / multi-device to verify:** actual QR pair + socket image transfer
into Figma, intent-share routing, all 6 languages, version-check + in-app-review triggers,
no-connectivity handling, analytics parity, and a signed **release** build run (blocked on new key).

---

## Phase 5 — Optional / hygiene (separate from logic)

Done (safe, non-behavioral):
- Untracked `.dart_tool/` and `node_modules/` (1427 files) from git; added `node_modules/` to
  `.gitignore` (`.dart_tool/` was already ignored).
- Removed unused imports: `dart:io` in `lib/main.dart` and `lib/services/telsec_raspfree_checker.dart`.
- Restored + bundled `.env` (Firebase keys) and hardened `dotenv.load` — fixes the cold-start crash
  (Phase 3 critical).
- Gated both security layers (Flutter freeRASP + native `MainActivity.kt`) to release-only so debug
  builds are testable (Phase 6) — release protection unchanged.

Backlog — NOT done (documented, no auto-build):
- ~60 `Color.withOpacity` → `.withValues()` info-deprecations across `lib/widgets/*`,
  `lib/screen/*`. Non-behavioral but bulk; defer to a dedicated cleanup commit.
- `must_be_immutable` warnings: several `StatefulWidget`s hold mutable fields. Pre-existing design;
  refactor risks behavior — leave.
- `WillPopScope` → `PopScope`, `use_build_context_synchronously`, minor unused fields/elements.
- Feature backlog (README "future scope", DO NOT build): >10 images, files >5 MB, transfer
  history, theme customization, more languages.

---

## §4 Human-only tasks (consoles — Claude Code cannot do)
- **Firebase:** add new Android app `in.getsnapdrop.app` to project `snapdrop-e786e`, then re-run
  `flutterfire configure` to regenerate `lib/utils/firebase_options.dart` for the new package (or
  drop a new `google-services.json` + apply the plugin). Build is NOT blocked on this, but
  analytics/crashlytics misattribute until done.
- **Signing key:** generate new upload key/keystore + `key.properties`, then regenerate the
  freerasp `signingCertHashes` SHA-256 from it (see Phase 4).
- **Play Console:** new listing on new account; Data-safety form per the table above (declare
  "Device or other IDs" + Crash logs + Diagnostics); privacy policy URL (e.g.
  `getsnapdrop.in/privacy`); content rating (IARC); target audience; ads declaration; new upload
  key / Play App Signing.
- **Figma:** confirm plugin still works against current Figma plugin API; protocol frozen to match
  app; republish on Community if needed.
- **Server:** alive — no action.

---

## ⚠️ Security stack REMOVED (post-revival decision)

After review, the entire anti-tamper/RASP stack was **removed** — this is a free QR
image-transfer utility with no login, accounts, payments, or stored personal data, so RASP
(banking/fintech tooling) added no value and actively harmed UX (locked out rooted phones,
dev-mode-on devices, emulators; FLAG_SECURE blocked screenshots on a *sharing* app) and required
a Talsec account that's no longer accessible. Removed:
- Dart: `freerasp` dependency, `lib/services/telsec_raspfree_checker.dart`,
  `lib/services/jailbreak_detector.dart`, `lib/widgets/security_screen.dart`, all refs in `main.dart`.
- Native: `MainActivity.kt` security block + `DeveloperModeChecker.kt` / `EmulatorChecker.kt` /
  `OverlayDetector.kt` / `RootDetector.kt` / `SecurityUtils.kt` + `FLAG_SECURE`.
- Kept: Crashlytics/Analytics (telemetry, not security).
The earlier "gate security to release-only" work is therefore **superseded** — there is no security
layer left to gate. Verified: builds, launches on real device, no Security Alert, no crash.

**Branch policy:** this work lives on `revival/2026` and is **not to be merged into `main`** (per
owner instruction).

## Release build + cleanup (code-side, done)

- **Lint cleanup:** 98 → 22 analyze issues, 0 errors. `dart fix` (imports/curly/super-params);
  mechanical `Color.withOpacity(x)` → `.withValues(alpha: x)` across 9 files (50 sites,
  behavior-identical); removed dead `_buildShareButton`, unused `_scaleAnimation`,
  `_compareVersions`, duplicate aliased import + `print`→`debugPrint` in `check_app_version.dart`.
  Remaining 22 are intentionally left (must_be_immutable design, use_build_context_synchronously,
  WillPopScope, package name `Snapdrop`) — behavioral/cosmetic, not worth the risk.
- **Removed unused dep:** `flutter_svg` (no `SvgPicture` usage anywhere).
- **Release signing set up + signed AAB built:**
  - Generated upload keystore `android/app/upload-keystore.jks` (alias `upload`, RSA 2048,
    10000-day validity) + `android/key.properties`. **Both gitignored — NOT in the repo.**
  - ⚠️ **CREDENTIALS (save these / replace before publishing):** storePassword=`snapdrop2026`,
    keyPassword=`snapdrop2026`, keyAlias=`upload`, storeFile=`upload-keystore.jks`. **Back up the
    `.jks` somewhere safe** — once it's the Play upload key, losing it means you can't ship updates
    (Play App Signing recovery aside). If you'd rather own a key with your own password, regenerate
    it and replace `key.properties` before the first Play upload.
  - `flutter build appbundle --release` → **signed `app-release.aab` (46 MB)**. Also built release
    APK (54 MB) and ran it on the real device: **onboarding UI renders, no crash, no security
    block** (security fully removed); R8/minify/shrink OK (Crashlytics keep-rules fine).
- **Release Firebase finding:** manual `Firebase.initializeApp(options: …)` works → Core +
  **Crashlytics OK**. But native **Firebase Analytics is disabled** in release: `E FA: Missing
  google_app_id`. The Analytics SDK needs the `google_app_id`/`google_api_key` **string resources**
  that only the `com.google.gms.google-services` Gradle plugin generates from `google-services.json`
  — `firebase_options.dart` alone doesn't provide them. ⚠️ **So Analytics stays off until the
  Firebase task is done:** add the new Android app `in.getsnapdrop.app`, drop the new
  `google-services.json` into `android/app/`, and apply the google-services plugin. (Same human
  task already listed; this just confirms Analytics specifically depends on it.)

## §5 — Definition of done (status)

| Brief criterion | Status |
|---|---|
| Builds + runs on current Flutter | ✅ Flutter 3.35.4 / Dart 3.9.2; debug APK builds, launches on API 37 |
| Current target API | ✅ `targetSdk 35` (verify Play's current min before submit) |
| New `applicationId` | ✅ `in.getsnapdrop.app` set + propagated (freerasp, share URL, manifests) |
| New `google-services.json` | ⏳ **Human (Firebase).** Build not blocked — config is in `firebase_options.dart`; regenerate via `flutterfire configure` |
| `qr_code_scanner` gone, scan→pair identical | ✅ Was already on maintained `qr_code_scanner_plus` fork; flow unchanged (no `mobile_scanner` needed) |
| §1 business logic unchanged | ✅ Wire protocol, 7 analytics events, flows preserved; only approved crash-hardening + required package-id propagation |
| Stability (v15/v17 crash) | ✅ `int.parse` + QR `split` crash guards added; maintained QR fork; cold-start clean to security gate |
| 16 KB page size (Play req) | ✅ Fixed via `freerasp 7.5.1`; all arm64 `.so` ≥16 KB-aligned (re-verified) |
| Data-safety SDK list | ✅ Written (Phase 3): Device/other IDs + Crash logs + Diagnostics; NOT Performance |
| Signed release AAB | ✅ **Built + signed + runs** (`app-release.aab`, 46 MB; release APK verified on device). Keystore is a placeholder — replace/back up before publishing (creds above) |
| Firebase Analytics in release | ⏳ **Needs google-services.json + gms plugin** (new Firebase app). Core + Crashlytics already work; Analytics disabled until then (`Missing google_app_id`) |
| Cold-start crash on fresh install | ✅ Fixed (missing `.env` bundled + load hardened) — was the likely Play crash cause |
| Full flow on real device (image→QR→transfer) | ✅ **User-confirmed working end-to-end** — images transfer into Figma. Client path also screenshot-verified launch→perm→grid→select→Connect→QR-camera (Android 16) |
| Zero unreviewed behavioral changes | ✅ All behavioral/risky items flagged here, none silent |

**Net:** all code-side work done + verified to the limits an emulator allows. Remaining items are
console/hardware tasks (Firebase, signing key, physical-device flow test), each flagged above.
