# What the Firebase numbers actually say

11 Sep 2026. Read from Crashlytics, Release Monitoring, Analytics and
Performance on the same afternoon. Nothing here is modelled — every figure is a
reported one, and where two reported figures disagree that is called out rather
than smoothed.

---

## 1. Ignore the "Healthy release" badge

Release Monitoring, last 24 hours, says **100% crash-free users, 100%
crash-free sessions, good stability**. In the same panel, the top issue lists
**10 crashes affecting 16.67% of users**.

Both are "true". The stability figure counts only users on a sessions-capable
Crashlytics SDK, and in that window there were **2 active users**. A green badge
computed over two people is not a signal, and if it is the number being watched
it is worse than no number, because it says the opposite of the truth.

**The honest figure is the 90-day one: 40.83% crash-free users.** Roughly three
users in five crash.

## 2. The funnel, and it is the whole story

Last 28 days of analytics, against 312 first opens:

| Event | Users | Share of first opens |
|---|---|---|
| first_open | 312 | 100% |
| tutorial_begin | 248 | 79.5% |
| app_launch | 141 | 45.2% |
| **app_exception** | **179** | **57.4%** |
| **app_remove** | **192** | **61.5%** |
| transfer_started | 5 | 1.6% |
| file_share_completed | 5 | 1.6% |

**Sixteen people in a thousand ever complete the one thing this app does.**
Five users, fifteen transfers — so the handful who get through do use it
repeatedly, three times each. The product works. Almost nobody reaches it.

## 3. The two numbers that match

```
crashed, 90 days      59.2% of users     (1 − 0.4083)
uninstalled, 28 days  61.5% of first opens
```

Different windows and different denominators, so this is not proof of
causation and should not be quoted as if it were. But the gap between the
share of users who hit an exception (57.4%) and the share who uninstall
(61.5%) is four points. **The most likely reading is that crashing and leaving
are the same event, seen twice.**

Retention supports it. Week 1 retention is 6.7%, week 2 is 2.6%, and every
week after that is 0.0%.

## 4. Where this happens, and to whom

Top countries are **Brazil (52), Spain (24), Italy (15), Argentina (14)** —
overwhelmingly not English-speaking. Top devices are **Samsung A-series**:
A546B, A175F, A566B, A155F, A346B. Mid-range Android, not flagships.

That matters for the crashes already fixed. Two of them — the album list
resolving after the user has left, and the sender id arriving after the first
build — are **races that a slower device and a slower network lose more often**.
This is exactly the population that hits them.

## 5. App start is 47% slower than it was

544 ms at the 90th percentile, up 47% over 60 days, down 6% in the last 7.
Not a crash, but a first impression, on the devices above.

## 6. What this is evidence for

287 users crashed over 90 days. **Not one of them could tell the developer what
they were doing when it happened.** What arrived instead was an obfuscated
frame with no symbol file, which is why the top three issues needed an
afternoon of reading guard clauses to identify rather than one report with a
screen name on it.

That is the argument for the feedback tool now wired into this app, stated in
this app's own numbers.

## 7. What to do, in order

1. **Ship the crash fixes.** They are committed and unreleased. Everything else
   on this page is downstream of 59% of users crashing.
2. **Keep the symbols.** Build with `--obfuscate --split-debug-info=symbols/`
   and archive that directory per release. Without it every future report costs
   what these cost.
3. **Re-measure after the release**, on the 28-day window, not the 24-hour one.
   The numbers to watch are app_exception share and app_remove share, together.
4. **Then look at the funnel.** 79.5% start the tutorial and 1.6% finish a
   transfer. Once crashes are not eating the difference, whatever is left is a
   product problem and worth a proper look — including whether an
   English-first flow is right for an audience that is mostly not.

---

## Update, 5 Oct 2026 (1.0.3 live at 100%, 35 hours)

Read from Crashlytics (30 days), the Analytics overview export (1 Jan – 5 Oct)
and Play Console.

**Growth is real; activation is not.** Play: 15.9K impressions (+98%), 1.03K
acquisitions (+259%), 39.8% listing conversion, installed audience 156 → 497
in three weeks. Analytics, all of 2026: 1,353 first opens → 88
`pairing_started` (6.5%) → 111 `file_share_completed`. 836 `app_remove`
(62%). Week-1 retention 5.5%.

**Crash-free users, 30 days: 45.6%** (1.2K crash events, 563 users). Almost
all of it is 1.0.1, still installed on devices that have not updated: three
null-check issues (332, 298, 286 events), Remote Config "unable to connect"
(87), `CameraException(404, No barcode view found)` (59), photo_manager
thumbnail failures incl. an OOM (49 + 3). Those code paths are fixed or gone
in 1.0.3. Play's 0% user-perceived crash rate is not a contradiction: these
are Dart errors recorded `fatal: true`, not process deaths.

**1.0.3 has one issue** — 3 users, first launch, ~15 s after install. Decoded
by rebuilding 1049eba with `--save-obfuscation-map`: `State.setState` from
`_OnboardScreenState._changeLanguage` (onboard_screen.dart:70). Changing the
language rebuilds the app, disposing the screen before the prefs awaits
finish. Fixed in 1.0.4 with a `mounted` guard.

**A dead end found while testing:** on a first run the QR camera only starts
from the tour's callbacks, and the tour's Skip button (new in 1.0.3) fires
none of them. Skip on the QR tour left an idle viewfinder that did nothing.
1.0.4 makes the idle viewfinder start the camera.

**Every `pairing_failed` (69) is `invalid_qr`** — 44% of scans are a QR that
isn't Snapdrop's. The invalid-QR state already explains it and links the help
sheet; watch this ratio after 1.0.4.

**Symbols were never kept.** `extra-gen-snapshot-options=--obfuscate` in
gradle.properties discarded the map, so every Dart frame read `iq.ahb
(tVe:1221)`. 1.0.4 builds through `tool/build_release.sh`
(`--obfuscate --split-debug-info=symbols/<version>`, uploaded to Crashlytics).

What to watch after 1.0.4: crash-free users on 1.0.3+ only (filter by
version), `pairing_started / first_open`, `app_remove / first_open`.
