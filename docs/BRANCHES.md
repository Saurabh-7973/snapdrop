# Which branch is this app, actually

`main` is not the line that ships. Anyone who assumes it is — including a
future reader of this repo, and including whoever wrote this — will reason from
the wrong tree.

## The state, as of 13 Sep 2026

```
main tip                d223b9e  2025-03-23  "UI, bug fixes and language implemented"
guidester-wiring tip    4ca8be7  2026-09-13  "version code 5"

main   ← guidester-wiring   101 commits
main   → guidester-wiring     4 commits (2024-07 to 2025-03, never merged forward)
```

**`main` was abandoned in March 2025.** Everything from 2026 is off it:
`revival/2026` (republish prep, Firebase reconfigured for `in.getsnapdrop.app`,
the anti-tamper stack removed), `quality/2026` (the audit and the crash-class
fixes), `design/2026`, `flow/2026`, and the Guidester wiring on
`guidester-wiring`.

**The build live on Play — 1.0.1 (4) — was cut from this line, not from main.**
That is the fact that settles which tree is canonical in practice, whatever the
default branch says.

## Consequences

- **Do not merge a release branch into `main` as a release step.** It is a
  101-commit merge across eighteen months of divergence, with four stale
  commits on the other side. It is its own piece of work.
- **Cut bundles from a tag, not a branch tip.** A branch moves; a tag is the
  tree you can rebuild from after a failed check.
  `snapdrop-internal-1.0.1+5` → `4ca8be7`.

## Open, and deliberately not done in a hurry

Reconciling `main` with the 2026 line. It needs those four stale commits read
properly — README, gitignore, a Gradle change and a UI/language commit — rather
than fast-forwarded over or discarded. Not an hour before a bundle.
