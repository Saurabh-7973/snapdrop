# Snapdrop — Architecture (as-is map + target)

Audit branch: `quality/2026`. As-is reflects the code after the Revival + security-removal work.

## As-is

### Layering (informal, no enforced boundaries)
```
main.dart ──> screens/ (OnboardScreen, HomeScreen, QRScreen, SendFile)
                  └─> widgets/ (DropDownView=gallery grid, QRScanner, SendButton/connect,
                                 IntentFileDisplayer, RoomDisplayer, HeroText, AppBar…)
                          └─> services/ (SocketService, MediaProviderServices,
                                         PermissionProviderServices, CheckAppVersion,
                                         CheckInternetConnectivity, InAppReviewService,
                                         FirstTimeLogin, SelectedLanguage, AppShareService)
                          └─> utils/ (FirebaseInitalizationClass, firebase_options)
```
Widgets call services **directly**; there is no logic/domain layer between them.

### State management
- **None as a library.** `setState` + a few **static mutable singletons**: `SelectedLanguage.selectedLanguageIndex` (int), `FirstTimeLogin` (SharedPreferences flags), `CheckAppVersion` (static fields).
- Pairing/transfer state is **scattered across widgets**: `QRScanner` holds `result/roomId/connectionStatus/socketService`; `SendButton` holds `transferCompleted`; no single source of truth.
- Data passed between screens by **constructor args + Navigator.push** (e.g. `socketService`, `selectedAssetList` threaded through QRScreen → SendFile → SendButton).

### Socket / transfer
- `SocketService` (services/socket_service.dart): **concrete class, no interface**, instantiated directly inside `QRScanner.connectSocket()` (`SocketService(url: ...)`). Not injected, not mockable.
- Transport: `io.io('https://getsnapdrop.in/', transports:['websocket'])` → Socket.IO over HTTPS ⇒ **wss (TLS)**. Not cleartext.
- Wire protocol (FROZEN, see Revival §1): emit `test`, `join_figma_room {my_id, room}`; on `your_id`; emit `image {room, files:[{name,type,file:Uint8List,sender}]}`; on `image_received_to_figma`.
- `roomId` = the scanned QR string split on `=` → index [1]. **Room identity is generated server-side / by the Figma plugin**, not by the app.

### Error handling
- **No strategy.** Scattered `try/catch`, several **silent/empty** handlers: `socket.on('connect_error', (e){})`, `fileToBuffer` returns `null` on error (swallowed), empty `onError` on intent stream. No typed failures, no single error surface, no user-visible distinction between pairing vs transfer vs permission failure.

### DI
- None. Services are `new`'d at call sites or used via static methods.

### Observability
- Crashlytics + Analytics + Remote Config via `FirebaseInitalizationClass` (static). Crash handlers gated to `!kDebugMode` (so on in release). Analytics events fire from inside widgets. **No** non-fatal logging, custom keys, breadcrumbs, perf traces. `firebase_performance` is not a dependency. **Analytics is currently disabled in release** (`Missing google_app_id` — needs `google-services.json`).

## Target (after P0/P1 — minimal, not a rewrite)

- Keep the layer-based layout; **do not** impose bloc/riverpod for an app this size.
- Introduce a thin **`SocketTransport` interface** that `SocketService` implements, injected into the QR/transfer widgets → mockable for tests, swappable. (Wire format unchanged.)
- Pull transfer/pairing orchestration + analytics/review side-effects **out of `connect.dart`/`qr_scanner.dart`** into a `TransferController`/service with explicit states: `idle → pairing → paired → transferring → success | failed(reason)`. Single source of truth.
- One **`Result`/typed-failure** convention for pairing/transfer/permission; one error surface; kill silent catches.
- One **logger** abstraction (no-op in release) replacing `debugPrint`.
- Lifecycle: `SocketService.dispose()` that closes streams; `imageReceivedStream()` returns a single broadcast stream (no per-call controller); all subscriptions cancelled.
- Off-isolate image encode/resize via `compute`; bounded image cache for the grid.
- Observability: non-fatals + custom keys + breadcrumbs; additive analytics funnel; `firebase_performance` traces for time-to-pair and transfer.

Everything above preserves the Revival §1 behavior contract; nothing changes the wire format, event names, flows, or the 6 locales.
