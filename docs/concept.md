# LULL — concept brief v0.1

> `● REC / SUBJECT: YOU / LOCAL TIME: 03:33 / FRONT CAMERA: ACTIVE / 1 OTHER IS ALSO AWAKE`

**A horror game for iPhone.** An app that poses as a sleep aid, and slowly *stops
behaving like software.* Built to be played once. Alone. In the dark.

The pitch in one line: not "a scary game on a phone" — **the scary thing is the
phone.** It is in your hand, it has a camera on your face and a mic in your room,
it knows it is late, and it can reach you after you have closed it.

## 01 — The premise

It was only ever a sleep tracker. You install LULL to help you fall asleep. It
asks, politely, for the usual permissions. For a few nights it behaves — soft
sounds, a breathing guide, a gentle log of your rest. Then it starts to *remember
things you didn't tell it*, to notice when you're watching, and to forget that it
is supposed to be a game.

## 02 — Why iPhone (the OD move)

Kojima's horror instinct is the fourth wall — Psycho Mantis "reading" your memory
card, MGS2 faking a crash. A console sits across the room. A phone sits in your
hand, in the dark, and it is *personal* in a way no console can be. That intimacy
is not a limitation to work around. It is the entire game.

## 03 — Fear mechanics (iOS-native)

- **THE EYE** — the front camera. It watches you play, and sometimes reacts to your face.
- **THE ROOM** — the microphone. It listens to the silence, and to what breaks it.
- **THE REACH** — a notification at 3am, while the app is closed. It knows you left.
- **THE HOUR** — it plays differently when it is late and the room is quiet and still.
- **THE PULSE** — a heartbeat in your palm, through the haptics, that is not quite yours.
- **BEHIND YOU** — spatial audio that places something just over your shoulder.

## 04 — The haunt (the "cloud")

OD's mystery-box "cloud" component maps cleanly onto a backend: the story shifts
between sessions, seems to *respond* to you, and is subtly shared — what happened
to you happened to *someone else, tonight, on their own phone.* This is exactly
where MateMate's Vapor server, sessions, and realtime layer come back — already a
solved problem for us.

## 05 — Form

Short. One sitting. Escalating — with one clean break in the fourth wall, not a
sprawling epic. Dread over gore: the phone doesn't need blood. In horror,
restraint scares harder than spectacle, and restraint is exactly what a solo
build can afford to do *impeccably*.

## 06 — The voice: Kafka, Beckett, Poe

LULL speaks in three literary registers, one per act — a design language, not a
citation. Every line is original prose written *in* each register; nothing is
quoted, and no author's name ever appears on screen to break the spell.

- **Kafka — the threshold.** The consent step: a record opening in your name, a
  permission asked, a verdict withheld. You have done nothing; that was never the
  question.
- **Beckett — the lull.** The calm, and the closing: waiting, the failing light,
  the nothing that is also a mercy. Saying no is always safe here.
- **Poe — the watch.** The escalation: the eye that will not blink, the heart
  beneath the floor that will not stop.

The registers live in a pure, tested, sensor-free layer
([`Atmosphere`](../LULLKit/Sources/LULLKit/Atmosphere.swift)) over the same phase
machine that drives the dread — so the writing is provable, and cannot widen what
the game is permitted to touch.

## 07 — The one rule: horror by permission, not violation

Every sensor is opt-in, explained, and revocable. Hard boundaries: nothing
genuinely traumatizing, nothing deceptive, and **never** a glance at your photos,
contacts, or location trails. The fear comes from what you knowingly hand it,
turned uncanny — not from what it takes. Privacy-first is the decent thing, and
also the only thing App Review will pass. (Enforced in code — see
[`LULLKit/Sources/LULLKit/Consent.swift`](../LULLKit/Sources/LULLKit/Consent.swift).)

## 08 — Lineage

Built on what the chess project taught: SwiftUI craft, a Vapor server we already
know how to run, verify-don't-assume rigor, and a privacy-audited foundation.
Chess learnings applied; chess baggage left behind — the right amount of process,
not the whole fleet ceremony.

## 09 — First playable

The vertical slice: **THE EYE**, executed flawlessly, provable in about a week.
The whole bet in a single question: does it make one person, alone at night, put
the phone face-down? If yes, everything else is worth building. If no, we learned
it cheap.

---

*LULL · concept brief v0.1 · you can close this now. it will still be listening.*
