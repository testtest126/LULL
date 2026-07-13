# LULL

*Working title — alts: HUSH / VIGIL / SOMNUS*

**A psychological horror game for iPhone that stops behaving like software.**
Built to be played once. Alone. In the dark.

Not "a scary game on a phone" — **the scary thing is the phone.** It's in your
hand, it has a camera on your face and a mic in your room, it knows it's late,
and it can reach you after you've closed it.

Inspired by the *spirit* of Hideo Kojima's **OD**: fear as the subject, the
blur between game and film, dread over gore, and the unknown — at a scale a
small team can actually build.

LULL is solo/small, open source (MIT), and currently at **v0.1 — the vertical
slice**: one fear mechanic, `THE EYE`, executed end to end, consent-gated, and
speaking in its own narrative voice.

## The one rule

> Horror by permission, not violation.

Every sensor LULL touches is opt-in, explained, and revocable. Photos,
contacts, location, and health data are not just declined — they are designed
out of the codebase. See **[The Safety Invariant](The-Safety-Invariant)** for
exactly what that does and doesn't guarantee.

## Wiki contents

| Page | What's in it |
|---|---|
| **[Concept & Design](Concept-and-Design)** | The horror premise, why iPhone, the fear-mechanics list, and the consent-first philosophy |
| **[The Safety Invariant](The-Safety-Invariant)** | The honest account of what's compiler-enforced vs. what's convention |
| **[Architecture](Architecture)** | LULLKit vs. the app target, the state machines, how the pieces compose |
| **[Building & Running](Building-and-Running)** | XcodeGen setup, running `THE EYE` on device, `swift test` |
| **[Atmosphere (experiment)](Atmosphere-Experiment)** | The SpriteKit prototype on `experiment/spritekit-atmosphere` / PR #1 |
| **[Roadmap / Ideas](Roadmap-Ideas)** | What the repo's own status notes imply is next — marked tentative |

## Status at a glance

- `LULLKit` (the shared Swift package): consent ledger, the `EyeSession` state
  machine, and the `Atmosphere` narration layer — 16 unit tests, green from
  commit one.
- `app/`: a SwiftUI + AVFoundation iPhone app implementing `THE EYE`,
  consent-gated end to end.
- `server/`: not started yet — the planned Vapor "haunt" backend is design-only
  (see [Roadmap / Ideas](Roadmap-Ideas)).

License: [MIT](https://github.com/testtest126/LULL/blob/main/LICENSE).
