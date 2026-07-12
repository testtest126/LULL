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

Reusing what the [MateMate chess project](https://github.com/testtest126/chess)
taught — SwiftUI craft, a
Vapor server we already know how to run, verify-don't-assume rigor, and a
privacy-audited foundation.

- **`LULLKit/`** — the shared Swift package: domain models + the consent
  foundation. Buildable and tested from commit one (the ChessKit pattern).
- **`app/`** — the SwiftUI iPhone app (the vertical slice, `THE EYE`). Built in
  Xcode via `app/project.yml` (XcodeGen); depends on `LULLKit`.
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

## The voice — Kafka, Beckett, Poe

LULL narrates in three literary registers, one per act of the experience:

| register | governs | the feeling |
|---|---|---|
| **Franz Kafka** | the threshold — consent | a record opening in your name; a verdict withheld |
| **Samuel Beckett** | the lull — the calm & the endings | waiting, the failing light, the nothing that is a mercy |
| **Edgar Allan Poe** | the watch — the escalation | the eye that will not blink; the heart beneath the floor |

It is a design language enforced in a **pure, tested, sensor-free** layer
([`Atmosphere`](LULLKit/Sources/LULLKit/Atmosphere.swift)) over the same phase
machine that drives the dread — so the writing is provable and can never widen
what the game is permitted to touch. Every line is **original prose in each
register, never a quotation**, and no author's name appears on screen to break
the spell.

## Status

**v0.1 — the vertical slice.** `LULLKit` (consent, the `EyeSession` mechanic, and
the `Atmosphere` voice) is tested and green — 16 tests, green from commit one; the
SwiftUI + AVFoundation app in [`app/`](app) implements `THE EYE`, consent-gated,
speaking in the three registers above. Built in Xcode (see
[`app/README.md`](app/README.md)). Not scary yet — but it watches, it has a voice,
and it never breaks the rule.

## License

MIT — see [LICENSE](LICENSE). Build on it.
