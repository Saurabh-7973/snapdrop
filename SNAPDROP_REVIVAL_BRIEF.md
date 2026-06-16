# Snapdrop (AirDrop for Figma) — Revival & Republish Brief
**For:** Claude Code · **Goal:** republish on a new Google Play account under a new package ID · **Prime directive:** preserve all business logic.

---

## §0 — Read this first (working protocol)

This is a Flutter app — *"Snapdrop — AirDrop for Figma"*: phone → Figma image transfer via QR pairing + socket.io + a companion Figma plugin. It was live on Google Play; the developer account was then closed **for inactivity** (~Jan 2026), not for a violation. The code hasn't been touched in ~2 years. We're reviving it to republish on a fresh account.

**You are not rewriting this app.** You are modernizing the scaffolding around *unchanged behavior* and fixing the specific issues that blocked its last submissions. Treat any behavioral change as a defect unless I (the human) approve it.

Follow this for the whole job:
- Work on a new branch `revival/2026`. Commit after every phase, clear messages, never force-push.
- After each phase: `flutter analyze` clean, app builds, app runs. Don't advance on a broken tree.
- **Flag, don't guess.** If a fix would change behavior, a wire/protocol format, an analytics event, or a user-facing flow → STOP and ask me. List the options. Never "improve" silently.
- Keep a running `REVIVAL_LOG.md`: what changed, why, and everything you flagged. I read it before testing.
- Smallest change that restores compatibility. No refactors-for-taste mixed into compatibility work.

---

## §1 — PRIME DIRECTIVE: business logic that must NOT change

These behaviors *are* the product. Adapt them to new APIs only where behavior is provably identical. Any change to *what they do* → flag for review.

- **Image selection** (`photo_manager`): album list, grid view, multi-select, current selection limit.
- **QR pairing handshake**: app scans the QR the Figma plugin shows → joins the socket room. Pairing sequence and room/session identifiers unchanged.
- **Socket.io transfer protocol**: connection target, room model, event names, and the image payload format sent to the plugin. ⚠️ This is the contract between app and plugin — change it and the two stop talking. **Treat the wire format as frozen.**
- **Intent sharing**: receiving images shared from other apps into Snapdrop and routing them into the send flow.
- **First-run gating**: onboarding + showcase view (`first_time_login`). Same triggers, same once-only behavior.
- **Localization**: same 6 languages (en, hi, es, pt, ar, zh), same `.arb` keys. Don't drop or rename keys.
- **Version / force-update check** (`check_app_version` + `flutter_upgrade_version`): same prompt behavior.
- **In-app review** prompt: same timing/conditions.
- **Connectivity check** before sending: preserved.
- **Firebase Analytics events**: keep event names + params identical so historical analytics stay continuous.
- **Permission flows**: camera (QR) and photos/storage (images) — same request points, updated only as Android 13+ requires.

---

## §2 — The three components (all must work together)

The product is not just the app. Verify all three or it ships dead.

1. **Flutter mobile app** — the artifact going to Play. *(Main focus of this brief.)*
2. **Figma plugin** (`/Plugin`, `index.html` / `index.js`) — runs in Figma, receives the images. Separate publishing channel (Figma Community), but its socket protocol is shared with the app → **frozen**.
3. **Socket relay server** — the backend the app + plugin connect through (endpoint is in `lib/services/socket_service.dart`).

### ⚠️ CRITICAL PRE-CHECK (Phase 0, before any code work)
Find the server URL in `socket_service.dart` and confirm the relay server is **still alive and reachable**. After 2 years it may be on an expired/free host and simply down — in which case the app cannot function no matter how clean the client is. If it's down: STOP and tell me. Redeploying the server is a prerequisite, not an afterthought.

---

## §3 — ROADMAP

### Phase 0 — Recon & safety net
- [ ] Branch `revival/2026`; start `REVIVAL_LOG.md`.
- [ ] **Server alive check** (above). Report status.
- [ ] Record current state: expected Flutter/Dart version, full `flutter pub outdated` output, current `applicationId`, `targetSdk`, Gradle/AGP/Kotlin versions.
- [ ] Try a baseline build on the *current* SDK as-is; capture what breaks (we want a "before" picture).
- [ ] Inventory the §1 business-logic surfaces in code (note file + function for each) so you know exactly what must stay invariant.
- [ ] Document the socket protocol from *both* app and plugin side (event names + payload shape) so parity can be verified later.

### Phase 1 — Toolchain & Android build modernization
*(Stale 2-yr Flutter projects break mostly here, not in Dart.)*
- [ ] Upgrade Flutter to current stable + matching Dart. `flutter doctor`.
- [ ] Gradle: bump Gradle wrapper, AGP, Kotlin to current. Add the `namespace` declaration in `android/app/build.gradle` (AGP 8 requires it; remove the deprecated `package` from `AndroidManifest.xml`). Migrate to the declarative `plugins {}` block in `settings.gradle` if not already.
- [ ] Java 17 (`sourceCompatibility` / `targetCompatibility` / `jvmTarget`).
- [ ] Set `compileSdk` + `targetSdk` to the level Play currently requires (**verify in Console** — was API 35 / Android 15 as of Aug 31 2025; may be higher now). Check `minSdk` meets Firebase/plugin minimums (likely 23).
- [ ] `AndroidManifest.xml`: Android 13+ media permissions (`READ_MEDIA_IMAGES`, plus `READ_MEDIA_VIDEO` / `READ_MEDIA_VISUAL_USER_SELECTED` only if actually used), camera permission, any `<queries>` needed for share intents. Keep permissions to the minimum the app truly uses.
- [ ] Get it compiling + launching on this toolchain **before** touching pub dependencies.

### Phase 2 — Dependency modernization (compatibility only)
Use `flutter pub outdated`; upgrade by domain, fix breakages, keep behavior identical. **Don't pin to guessed versions — resolve latest compatible in this environment.** Known landmines:

| Package (current pin) | What changed | Action (preserve behavior) |
|---|---|---|
| `qr_code_scanner` ^1.0.1 | **Discontinued**; crashes on AGP 8 / new Android — prime suspect for the v15/v17 stability rejections | Replace with `mobile_scanner`. Re-implement the *same* scan→pair flow; parsed-QR → room-join output must be identical. |
| `share_plus` ^9 | API changed (~v10): `SharePlus.instance.share(ShareParams(...))` replaces `Share.share(...)` | Migrate call sites; same shared content/behavior. |
| `receive_sharing_intent` ^1.4.5 | Moved to instance API (`ReceiveSharingIntent.instance.getInitialMedia()` / `getMediaStream()`) | Migrate intent-sharing code; same routing into send flow. |
| `firebase_*` (core ^3, analytics ^11, crashlytics ^4, performance, remote_config) | Major bumps; BoM alignment | Upgrade as a set. Keep all event names/params identical (§1). |
| `permission_handler` ^11 + `photo_manager` ^3 | Android 13/14 media-permission model | Upgrade; verify same permission UX and image access on 13/14/15. |
| `intl` ^0.19 | Often gates other upgrades | Bump; regenerate l10n; verify all 6 `.arb` still load. |
| `flutter_upgrade_version` ^1.1.5 | Niche / possibly unmaintained | If it blocks the upgrade, **flag it** — note `in_app_update` as the standard Android equivalent, but only swap with my OK (touches the update flow). |

- [ ] After upgrades: `flutter analyze` clean, fix deprecations, app builds + runs.

### Phase 3 — Fix the actual Play rejection blockers
The last submissions died on three things; address all:
- [ ] **Stability (v15, v17 "crashes during testing")** — the `qr_code_scanner` swap (Phase 2) is the likely fix. Also: pull old Crashlytics crashes if still visible, add defensive error handling on the scan / permission / socket paths, and confirm a clean cold-start on a **fresh-install** emulator (Play tests fresh installs).
- [ ] **Target API** — handled in Phase 1; confirm the *release* build targets the required level.
- [ ] **Data-safety mismatch ("Device or other IDs" undeclared)** — this is a *Console form*, not code (see §4). Your job: produce a precise list of what the app collects/transmits and via which SDK (Firebase Analytics/Crashlytics/Performance → device & instance IDs, diagnostics, crash logs; anything else), so I can fill the form accurately. Write it into `REVIVAL_LOG.md`.

### Phase 4 — Store-readiness (code side)
- [ ] **New `applicationId`** (old `com.saurabh7973.snapdrop` is permanently burned on Play). Set a new one, e.g. `in.getsnapdrop.app`. Update everywhere it's referenced.
- [ ] **Firebase re-registration**: because the package name changes, a new Android app for the new `applicationId` must be added to the Firebase project and a new `google-services.json` dropped in (the old one is keyed to the old package and will break analytics/crashlytics). Flag for me to do in the Firebase console.
- [ ] Release config: confirm R8/ProGuard keep-rules for Firebase etc.; build a signed **release AAB** (signing key itself is a human task — §4).
- [ ] App icons/splash via `flutter_launcher_icons` regenerate correctly on the new toolchain.

### Phase 5 — Optional improvements (SEPARATE commit; nothing here is business logic)
Do only the safe, non-behavioral ones; list the rest as backlog, don't implement:
- [ ] Repo hygiene: `node_modules/` and `.dart_tool/` are committed — remove from tracking, add to `.gitignore`.
- [ ] Clear deprecation warnings, dead code, unused deps surfaced by analyze.
- [ ] **Backlog only — DO NOT auto-build** (these are new features from the README "future scope"): >10 images, files >5 MB, transfer history, theme customization, more languages. Flag as future work.

### Phase 6 — Testing & business-logic parity verification
Produce **ONE** testable build, plus this checklist for me to run once:
- [ ] **Core flow**: select images → scan Figma plugin QR → pair → images arrive in Figma, intact, correct order.
- [ ] **Intent share**: share image(s) from gallery → Snapdrop → into send flow → transfer works.
- [ ] **First run**: onboarding + showcase appear once; don't reappear after.
- [ ] **Permissions**: camera + photos prompt correctly and access works on Android 13, 14, and 15.
- [ ] All 6 languages load and render.
- [ ] Version-check / update prompt behaves as before.
- [ ] In-app review trigger unchanged.
- [ ] No connectivity → correct pre-send handling.
- [ ] **Cold start on fresh install: no crash** (the thing review caught).
- [ ] Analytics events fire with the same names/params as before.
- [ ] Signed **release AAB** installs and runs from the bundle (not just debug).

---

## §4 — Human-only tasks (Claude Code cannot do these — I do them in the consoles)

Claude Code: do NOT attempt these; just hand me the inputs you prepared.

**Play Console**
- New app listing on the new account; new `applicationId`.
- **Data safety form** — declare "Device or other IDs" + Crash logs / Diagnostics (per the list Claude Code wrote in `REVIVAL_LOG`). This was the v15 rejection reason; get it exactly right.
- **Privacy policy URL** — required (Firebase collects data). Host one (`getsnapdrop.in/privacy` works) and link it.
- Content rating (re-run IARC questionnaire — I had a rating before), target audience, ads declaration, app access.
- **Signing**: new app = new upload key / Play App Signing (old key is on the dead account). Generate/enroll.
- Internal testing → (closed if wanted) → production.

**Firebase Console**
- Add the new Android app (new package) to the project; download new `google-services.json`.

**Figma (separate track)**
- Confirm the Figma plugin still works against the current Figma plugin API; republish on Figma Community if needed. Protocol stays frozen to match the app.

**Server**
- If the Phase 0 check found the relay server down, redeploy it before anything else matters.

---

## §5 — Definition of done
- Builds + runs on current Flutter, current target API, **new `applicationId`**, new `google-services.json`.
- `qr_code_scanner` gone, `mobile_scanner` in, scan→pair flow behaviorally identical.
- All §1 business logic verified unchanged via the Phase 6 checklist.
- Signed release AAB produced.
- `REVIVAL_LOG.md` complete: every change, every flag, the data-safety SDK list.
- **Zero unreviewed behavioral changes.** Anything risky was flagged, not silently done.
