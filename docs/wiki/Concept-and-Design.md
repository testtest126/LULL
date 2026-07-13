# Concept & Design

Source: [`README.md`](https://github.com/testtest126/LULL/blob/main/README.md),
[`docs/concept.md`](https://github.com/testtest126/LULL/blob/main/docs/concept.md),
[`CLAUDE.md`](https://github.com/testtest126/LULL/blob/main/CLAUDE.md).

## The premise

LULL poses as a sleep aid. You install it to help you fall asleep; it asks,
politely, for the usual permissions. For a few nights it behaves — soft
sounds, a breathing guide, a gentle log of your rest. Then it starts to
*remember things you didn't tell it*, to notice when you're watching, and to
forget that it's supposed to be a game.

The one-line pitch: not "a scary game on a phone" — **the scary thing is the
phone.** It's in your hand, it has a camera on your face and a mic in your
room, it knows it's late, and it can reach you after you've closed it.

## Why iPhone (the OD move)

The concept brief frames this as Kojima's fourth-wall instinct (Psycho
Mantis "reading" your memory card, MGS2 faking a crash) applied to a device
that's *already personal* in a way a console across the room never is. That
intimacy isn't a limitation to design around — per `docs/concept.md`, "it is
the entire game."

## Fear mechanics (iOS-native)

From the README / concept brief. **Only `THE EYE` is implemented** as of v0.1
— the rest are named design intent, not shipped features (see
[Roadmap / Ideas](Roadmap-Ideas)).

| Mechanic | The device turned against you | Status |
|---|---|---|
| **THE EYE** | The front camera — it watches you, and reacts to your face | Implemented (`THE EYE`, v0.1) |
| **THE ROOM** | The microphone — it hears the silence, and what breaks it | Named only |
| **THE REACH** | A notification at 3am, while the app is closed | Named only |
| **THE HOUR** | It plays differently when it's late and the room is still | Named only |
| **THE PULSE** | A heartbeat in your palm, through haptics, not quite yours | Named only |
| **BEHIND YOU** | Spatial audio, something just over your shoulder | Named only |

## Form

Short. One sitting. Escalating, with one clean break in the fourth wall — not
a sprawling epic. Dread over gore: the phone doesn't need blood. The concept
brief argues restraint scares harder than spectacle, and restraint is what a
solo build can afford to do impeccably.

## The voice: Kafka, Beckett, Poe

LULL narrates in three literary registers, one per act of the experience:

| Register | Governs | The feeling |
|---|---|---|
| **Franz Kafka** | The threshold — consent | A record opening in your name; a verdict withheld |
| **Samuel Beckett** | The lull — the calm & the endings | Waiting, the failing light, the nothing that is a mercy |
| **Edgar Allan Poe** | The watch — the escalation | The eye that will not blink; the heart beneath the floor |

This is a design language, not a citation. Every line in
[`Atmosphere.swift`](https://github.com/testtest126/LULL/blob/main/LULLKit/Sources/LULLKit/Atmosphere.swift)
is original prose written *in* each register — nothing is quoted, and no
author's name appears on screen, so the spell isn't broken. The registers live
in a pure, tested, sensor-free layer over the same phase machine that drives
the dread (`EyeSession.Phase`), so the writing is provable and structurally
cannot widen what the game is permitted to touch — see
[The Safety Invariant](The-Safety-Invariant) for what "cannot widen" means
precisely.

## The consent-first philosophy

Also documented in [The Safety Invariant](The-Safety-Invariant), but the
design rationale is worth stating plainly, in the project's own words
(`CLAUDE.md` / README):

- Every sensor is opt-in, explained, and revocable. Default is deny.
- Forbidden, forever: photos, contacts, location trails, health data, and
  anything read without the player knowing.
- No genuine harm — uncanny, not traumatizing; unsettling, but never
  deceptive about what's real. A fake "your data has leaked" is out; the
  dread is fiction and stays legibly fiction.
- No PII in the repo, logs, or telemetry, ever.

The fear is meant to come from what the player *knowingly* hands over, turned
uncanny — not from what is taken. Privacy-first is framed as both the decent
choice and the only one App Review will pass.

## Lineage

The project explicitly reuses lessons (not process) from an earlier project,
[MateMate (chess)](https://github.com/testtest126/chess): SwiftUI craft, a
Vapor server pattern, "verify, don't assume" rigor, and a privacy-audited
foundation. `CLAUDE.md` is explicit that the *ceremony* around that project
(multi-agent coordination protocols) doesn't apply here — LULL is small, and
keeps the rigor while dropping the ritual.
