# Snapdrop — Quality Audit Findings (Phase A)

Branch `quality/2026`. **Audit only — no code changed.** Severity per brief §3 (P0 before next
release · P1 high-impact next · P2 post-launch). Each: file · why · fix · risk-of-fixing.
Awaiting your scope approval before Phase B.

> Headline: after the Revival work, **no P0 is confirmed exploitable in the client** — transport is
> already TLS, Crashlytics works in release, R8 + Dart obfuscation are on, the crash blocker (.env)
> is fixed. The two things gating "is it safe to ship more" are an **investigation** (room-ID
> entropy, server-side) and **analytics being dead in release**. Most real wins are P1.

---

## P0 — assess before next release

### P0-1 · Session-hijack risk — room-ID entropy (INVESTIGATION, mostly server-side)
- **Where:** `socket_service.dart` `_joinFigmaRoom` (`room` = QR string after `=`); generation is in
  the **relay server / Figma plugin** (`/Plugin`, not in this repo's Dart).
- **Why it matters:** anyone who joins a victim's room receives their images. If room IDs are short,
  sequential, or guessable, a third party can join and intercept a QR-paired transfer. This is the
  single highest-value security question for a transfer app.
- **Fix:** confirm the server mints room IDs with ≥122 bits entropy (UUIDv4 / 32+ hex), single-use,
  short TTL, and that the server **rejects a second joiner** / scopes delivery to the paired pair.
  Client stays as-is if the server is sound.
- **Risk of fixing:** none client-side (read-only check). Server change is out of this repo — **flag
  to you**; touches the frozen protocol only if room format changes (then it's a §1 flag).
- **Status:** cannot verify from the client; needs the server/plugin source.

### P0-2 · Analytics dead in release (observability blind spot)
- **Where:** native FA — `E FA: Missing google_app_id` (release run). `firebase_options.dart` feeds
  Core/Crashlytics but **not** the native Analytics SDK.
- **Why it matters:** you ship with **zero analytics** despite the events firing — no funnel, no
  install/usage data, breaking the §1 "analytics continuity" goal.
- **Fix:** add the new Firebase Android app, drop `google-services.json` into `android/app/`, apply
  the `com.google.gms.google-services` plugin (the Firebase human task already on the list).
- **Risk of fixing:** low; standard FlutterFire. Verify event names unchanged (§1).

*(Transport TLS, Crashlytics-in-release, obfuscation, and the .env cold-start crash were P0 classes
the Revival work already closed — noted here as **resolved**, not open.)*

---

## P1 — high-impact, do next

### P1-1 · `imageReceivedStream()` leaks a controller + stacks listeners
- **Where:** `socket_service.dart:75` (new `StreamController` + `socket.on('image_received_to_figma')`
  **every call**, never closed); consumed in `connect.dart:69,116` with `.listen(...)` whose
  subscription is never cancelled.
- **Why:** each transfer registers another socket handler and an unclosed controller → duplicate
  review/analytics fires, growing memory, post-dispose callbacks.
- **Fix:** single broadcast stream created once; register `socket.on` once; cancel the subscription
  in `dispose`. Add `SocketService.dispose()` that closes the socket + controller.
- **Risk:** medium — touches the transfer-ack path (§1-adjacent). Behavior must stay: one ack →
  one `transferCompleted`. Cover with a mock-socket test first.

### P1-2 · No disposal of socket / subscriptions
- **Where:** `SocketService` never `.dispose()`d; `connect.dart` `.listen` not stored; intent stream
  in `main.dart` is re-subscribed in `didChangeAppLifecycleState` without cancelling the prior sub.
- **Why:** leaks + the intent stream can fire twice after resume.
- **Fix:** store/cancel all subscriptions; dispose socket when leaving the transfer flow.
- **Risk:** low–medium; verify resume-from-background still routes one intent share.

### P1-3 · Image encode/transfer on the UI isolate, full bytes in memory
- **Where:** `connect.dart` `sendFilesToServer*` → `originFile`/`fileToBuffer` (full `Uint8List`) →
  `sendImages` one emit per image; no resize/compress; `compute`/isolate: **none**.
- **Why:** selecting many or large images loads every full image into memory and blocks the UI →
  jank / OOM on low-end devices.
- **Fix:** read/encode off-isolate via `compute`; optional downscale before send; don't hold all
  bytes at once (stream per image). **Measure** transfer time + peak memory before/after.
- **Risk:** medium — must not alter the bytes the plugin receives unless you approve compression
  (that's a §1 flag — changes what arrives in Figma). Default: same bytes, just off-isolate.

### P1-4 · Gallery grid rebuilds wholesale + loads the entire album
- **Where:** `dropdown_view.dart` (`GridView.builder` ✓ but 9× `setState` at widget scope; selection
  toggles rebuild the whole grid); `media_provider.dart:15` `getAssetListRange(0, assetCount)` loads
  **every** asset at once. No `RepaintBoundary`/`cacheExtent`.
- **Why:** scroll jank + memory on large albums; selection tap rebuilds all cells.
- **Fix:** paginate `getAssetListRange`; isolate selection state so a tap rebuilds one cell;
  `RepaintBoundary` per cell; set `cacheExtent`; bound `PaintingBinding.imageCache`. **Profile**
  scroll on a 1k+ album before/after.
- **Risk:** low–medium; pure perf, no behavior change. Keep the "Up to 10" limit intact.

### P1-5 · Pervasive force-unwraps on crash-prone paths
- **Where:** 75 `!` in lib; hot spots `connect.dart` (25: `selectedAssetList!`, `socketService!`,
  `value!`, `reviewCounter!`), `qr_scanner.dart` (12), `socket_service.dart` (8), `firebase` (10).
  `fileToBuffer` can return null → `sendImages(file: null!)`-style paths.
- **Why:** null/empty (denied permission, failed file read, race) → uncaught crash exactly on the
  paths Play review exercises.
- **Fix:** guard with null-aware/early-return + typed failures (ties to error-handling refactor).
- **Risk:** low if mechanical; the value is exactly removing crash surface.

### P1-6 · No error-handling strategy (silent catches)
- **Where:** empty `connect_error`/`onError` handlers; `fileToBuffer` swallows; no user feedback on
  pairing/transfer failure.
- **Fix:** one `Result`/typed-failure convention; surface pairing vs transfer vs permission failures;
  log non-fatals to Crashlytics. (Pairs with §A target.)
- **Risk:** medium — defines new user-visible failure states; behavior-additive, flag any flow change.

### P1-7 · SocketService not behind an interface (untestable)
- **Where:** `qr_scanner.dart` `new SocketService(...)`.
- **Fix:** `SocketTransport` interface + inject; enables mocking for P1-8.
- **Risk:** low; mechanical, wire format unchanged.

### P1-8 · Observability gaps (Crashlytics depth + analytics funnel + perf traces)
- **Where:** `firebase_initalization_class.dart` + event sites.
- **Why:** crashes report but with no context; no funnel; no field perf data to prove P1-3/P1-4 helped.
- **Fix (additive only):** non-fatal `recordError` on caught exceptions (transfer/pairing/permission);
  custom keys (screen, transfer state, image count, payload size, paired); breadcrumbs along the flow;
  **keep all existing event names/params** and add a funnel
  (`pairing_started→pairing_success→transfer_started→transfer_success|transfer_failed{reason,image_count}`);
  add `firebase_performance` traces for time-to-pair + transfer duration.
- **Risk:** low; renaming an existing event is the only §1 flag — don't.

### P1-9 · CI is stale/broken
- **Where:** `.github/workflows/main.yml` — triggers on `saurabh_dev` only; Flutter `3.29.0` (project
  is 3.35); **creates `.env` from secrets that the app no longer uses** (dotenv removed); no
  `analyze`, no tests; builds unsigned (no keystore).
- **Fix:** trigger on `main`/PR; pin Flutter 3.35.x; drop the `.env` step; add `flutter analyze
  --fatal-infos` + `flutter test`; build AAB.
- **Risk:** none (tooling).

### P1-10 · Test baseline absent
- **Where:** `test/widget_test.dart` is the default counter boilerplate (doesn't match this app).
- **Fix:** unit-test transfer/pairing logic + failure paths via the P1-7 mock; widget-test core flows.
  Not chasing 100% — cover what breaks the product.
- **Risk:** none.

---

## P2 — post-launch polish (do NOT block release)

- **P2-1 · Strict lints:** `analysis_options.yaml` is default `flutter_lints`; adopt stricter
  (`very_good_analysis` or curated rules) + treat infos/warnings as errors in CI. 22 analyzer issues
  remain (`must_be_immutable` on mutable-field StatefulWidgets — HomeScreen/SendButton/QRScanner/etc;
  `use_build_context_synchronously`; `WillPopScope`→`PopScope`). Mechanical but churny.
- **P2-2 · `exit(0)`** in `connect.dart:318` close button — abrupt; use `SystemNavigator.pop()`.
- **P2-3 · `network_security_config.xml`** explicitly disallowing cleartext (defense-in-depth; transport already wss).
- **P2-4 · Dead code/no-ops:** `media_provider.dart` `assetCount - 1;` (lines 13,23 — discarded);
  commented-out blocks in `connect.dart` build.
- **P2-5 · Magic numbers** (`screenWidth/1.3`, `/2.6`, fixed heights) → named constants.
- **P2-6 · Logger abstraction** replacing scattered `debugPrint`.
- **P2-7 · Certificate pinning** — explicitly overkill here; note and skip.
- **P2-8 · Deeper structural refactor** (full controller/DI layering) — only if the app grows.

---

## Suggested Phase-B order (after your approval)
1. P0-2 + P1-9 (analytics/Firebase + CI) — unblocks measurement & observability.
2. P1-8 (Crashlytics depth + funnel + perf traces) — so 3–4 can be measured in the field.
3. P1-1/P1-2/P1-7 (socket lifecycle + interface) + P1-10 tests — correctness + testability.
4. P1-3/P1-4 (off-isolate encode + grid perf) — with before/after numbers.
5. P1-5/P1-6 (force-unwraps + error strategy).
6. P0-1 — report room-ID entropy once the server/plugin source is available.
7. P2s as time allows; not release-blocking.

**Ship gate:** P0-1 answered + P0-2 done + P1-1..P1-6 done = safe to release. P2 deferred.
