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

## Phase 6 — Runtime verification (emulator)

Ran `flutter run -d emulator-5554` on an Android 17 (API 37) emulator:
- ✅ Builds, installs, launches. Process `in.getsnapdrop.app` / `...MainActivity` reaches RESUMED
  in foreground, **no crash, no Firebase/RASP integrity block** → new applicationId works at
  runtime and freerasp package-id match is correct.
- 🛑 App then shows its **own** "Security Alert — This app cannot run on an emulator → Close App"
  (anti-tamper: `JailbreakDetector` / native `EmulatorChecker.kt` / freerasp `onSimulator`).
  **Working as designed.** Consequence: the full flow (image select → QR pair → transfer) **cannot
  be tested on an emulator** — requires a **physical Android device** (also needed for the real
  Figma-plugin QR). Per decision: test on physical device; security gates left untouched.
- The emulator run is what surfaced the 16 KB issue (now resolved, Phase 3).

**Still to run on a physical device (Phase 6 checklist from brief):** core transfer flow, intent
share, first-run once-only, camera+photos perms on Android 13/14/15, all 6 languages, version-check
prompt, in-app review trigger, no-connectivity handling, fresh-install cold start, analytics event
parity, signed release AAB install.

---

## Phase 5 — Optional / hygiene (separate from logic)

Done (safe, non-behavioral):
- Untracked `.dart_tool/` and `node_modules/` (1427 files) from git; added `node_modules/` to
  `.gitignore` (`.dart_tool/` was already ignored).
- Removed unused imports: `dart:io` in `lib/main.dart` and `lib/services/telsec_raspfree_checker.dart`.

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
