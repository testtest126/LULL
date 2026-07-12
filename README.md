# LULL

*Working title — alts: HUSH / VIGIL / SOMNUS*

**A psychological horror game for iPhone that stops behaving like software.**
Built to be played once. Alone. In the dark.

The pitch in one line: not "a scary game on a phone" — **the scary thing is the
phone.** It is in your hand, it has a camera on your face and a mic in your room,
it knows it is late, and it can reach you after you have closed it.

Inspired by the *spirit* of Hideo Kojima's **OD**: fear as the subject, the blur
between game and film, dread over gore, and the unknown — at a scale a small team
can actually build.

## The one rule — horror by permission, not violation

The binding constraint of the whole project (see [CLAUDE.md](CLAUDE.md)):

- Every sensor LULL touches is **opt-in, explained, and revocable.** Default is deny.
- **Hard boundaries:** nothing genuinely traumatizing, nothing deceptive, and
  **never** a glance at your photos, contacts, or location trails.
- The fear comes from what the player *knowingly* hands over, turned uncanny —
  not from what is taken.

Privacy-first is the decent thing here, and the only thing App Review will pass.
The allow-list is enforced **in code**: [`LULLKit`](LULLKit) has no way to even
*name* a forbidden sensor.

## Architecture

Reusing what the [MateMate chess project](../chess) taught — SwiftUI craft, a
Vapor server we already know how to run, verify-don't-assume rigor, and a
privacy-audited foundation.

- **`LULLKit/`** — the shared Swift package: domain models + the consent
  foundation. Buildable and tested from commit one (the ChessKit pattern).
- **`app/`** *(later)* — the SwiftUI iPhone app. Created in Xcode; depends on `LULLKit`.
- **`server/`** *(later)* — the Vapor **haunt server**: content that shifts
  between sessions, seems to respond, and is quietly shared between players.
  MateMate's online/session stack, reused.

## The vertical slice: `THE EYE`

One fear mechanic — the front camera watching the player — executed flawlessly,
provable in about a week. The whole bet in one question: **does it make one
person, alone at night, put the phone face-down?** If yes, everything else is
worth building.

## Fear mechanics (iOS-native)

| mechanic | the device turned against you |
|---|---|
| **THE EYE** | the front camera — it watches you, and reacts to your face |
| **THE ROOM** | the microphone — it hears the silence, and what breaks it |
| **THE REACH** | a notification at 3am, while the app is closed |
| **THE HOUR** | it plays differently when it is late and the room is still |
| **THE PULSE** | a heartbeat in your palm, through haptics, not quite yours |
| **BEHIND YOU** | spatial audio, something just over your shoulder |

Full concept: [`docs/concept.md`](docs/concept.md).

## Status

**v0.1 — concept + foundation.** Nothing scary yet: just the skeleton, and the
rule it will never break.

## License

All rights reserved (for now). Not open source.
