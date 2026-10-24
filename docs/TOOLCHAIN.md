# Build toolchain

This file exists because the move it records is invisible in the history.

## 11 Sep 2026 — Gradle 8.7 → 8.14.3, AGP 8.6.0 → 8.11.1

Both changes are in **`7740efe`**, a commit whose message is
*"fix: the QR screen crashed on the most ordinary path to it"* and says nothing
about the build environment. Nobody reading that log line — including whoever
wrote it, three weeks later — would know the toolchain moved underneath this
app while it was live on Play.

```
android/gradle/wrapper/gradle-wrapper.properties   gradle-8.7-bin → gradle-8.14.3-all
android/settings.gradle                            com.android.application 8.6.0 → 8.11.1
```

**If you are bisecting a build failure, start here.** A jump of that size
changes R8 defaults, manifest merging, Java target defaults and the Kotlin
plugin's expectations. The project compiles on it, which is not the same as
having been exercised on it: the app on Play is 1.0.1 (4), built before this
commit.

Before any bundle goes to Play, run the debug build by hand for five minutes —
share a file end to end, open the QR screen, background and resume the app.
Compilation is not the test.
