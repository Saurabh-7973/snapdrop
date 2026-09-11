# Guidester in a Snapdrop test build — what it changes, and what must be said

*Draft, 11 Sep 2026. Not legal advice, but this is a routine declaration rather
than a legal engagement — which is why Snapdrop is host number one.*

The overlay is wired and inert unless the build passes
`--dart-define=GUIDESTER_KEY`. Nothing here applies to the public release, which
passes no key and never runs a line of it.

---

## 1. Why this host, and not the other one

The first candidate was a sexual-health app whose privacy policy promises that
health information never reaches a server the developer can read. Its screenshots
would be health data about identifiable people. That is a legal review, not a
paragraph.

Snapdrop has none of it. It moves files between devices on a local network. There
is no account, no health data, no special category of anything. The declaration
below is ordinary.

## 2. What a screenshot can contain here

Be specific rather than reassuring. A Snapdrop screenshot can show:

- **File names and image thumbnails** of whatever the tester is sending. That is
  the app's main screen, so it is the most likely thing in any report.
- A room code and the names of devices on the local network, which can carry a
  person's name, since phones are often named after their owner.

None of that is a special category of personal data, and all of it is the
tester's own. It is still worth one line in the invite, because "it uploads a
picture of the screen you are on" means something concrete when the screen is
full of your own photos.

## 3. Play Data safety — the declaration

All **collected and transferred off-device**, purpose *app functionality*:

| Category | What is sent |
|---|---|
| Photos and videos | One PNG per comment, of the current screen. Overlay chrome is excluded; the app is not. |
| Device or other IDs | A random per-install id, plus device model and OS version. Not an advertising id, not a hardware id. |
| App activity | Comment text, screen name, tap point, app version, text scale, brightness, orientation, locale, route breadcrumb. |
| App activity — crash and error data | The last three exceptions of the session, up to 24 stack frames each, with the route. Sent with a comment, never on its own. |

Nothing else. No files are uploaded — only a picture of the screen, and only when
a tester taps send.

## 4. The privacy policy paragraph

Check the existing policy first for any sentence a test build makes untrue —
search for *on your device*, *never leaves*, *we cannot see*, *no screenshots*,
*not transmitted*. Snapdrop's whole pitch is that files move directly between
devices, so a line to that effect may well be in there. **The files still do.**
The screenshot is a separate thing and the paragraph should say so.

> During closed testing, this build includes a feedback tool. When you choose to
> send feedback, it uploads a picture of the screen you are looking at, the name
> you entered, a random identifier generated on your device, your device model and
> OS version, technical details about the screen, and any errors the app ran into
> while you were using it. Your files are not uploaded — they still travel
> directly between your devices, as they always have. Nothing is sent unless you
> tap send. You can ask us to delete your feedback at any time by contacting
> &lt;address&gt;, and we will remove it and the screenshots with it. This tool is not
> present in the public release of this app.

## 5. Deletion

The dashboard deletes one comment and its screenshot, or everything from one
tester, both behind a confirmation. Storage goes before the row, so a failure
cannot orphan a screenshot.

**One caveat to state honestly:** tester identity lives in device preferences, so
a tester who reinstalls becomes a new person to the system. "Delete everything
from this tester" reaches what that install sent, not what a previous install
sent. If someone asks for full erasure, ask whether they reinstalled.

## 6. Checklist before a build goes out

- [ ] Data safety updated on the tester track with the four rows above
- [ ] Privacy policy paragraph added, and the existing text checked for a
      sentence this contradicts
- [ ] Invite carries the §2 wording
- [ ] Screens walked on hardware and the resolver's answers recorded
- [ ] Key rotated — **after** the hardware walk, immediately before the build
- [ ] A build with no dart-define confirmed inert: no bubble, nothing sent
