# Roadmap / Ideas

> **Everything on this page is tentative.** LULL has no issue tracker or
> formal roadmap document in the repo. What follows is only what the repo's
> own status notes (README "Status" section, `CLAUDE.md`, the concept brief,
> and the fear-mechanics table) genuinely imply is next — not a commitment,
> not a schedule, and not anything beyond what's already written down
> somewhere in the project.

## What v0.1 says is done

Per the README's own "Status" section:

> `LULLKit` (consent, the `EyeSession` mechanic, and the `Atmosphere` voice)
> is tested and green — 16 tests, green from commit one; the SwiftUI +
> AVFoundation app in `app/` implements `THE EYE`, consent-gated, speaking in
> the three registers above. [...] Not scary yet — but it watches, it has a
> voice, and it never breaks the rule.

Two things worth noting precisely: the project's own words are **"not scary
yet"** — v0.1 is described as a proven mechanic and a working consent
foundation, not a finished horror experience. And the vertical slice's
purpose is explicitly a go/no-go test, per the concept brief: *"does it make
one person, alone at night, put the phone face-down? If yes, everything else
is worth building. If no, we learned it cheap."* No result of that test is
recorded in the repo.

## Implied next mechanics

The README's fear-mechanics table lists five more mechanics beyond `THE EYE`
that are named and designed but have no code yet (see
[Concept & Design](Concept-and-Design) for the full table):

- **THE ROOM** — microphone, listening to silence and what breaks it
- **THE REACH** — a local notification at 3am, app closed
- **THE HOUR** — behavior that varies with how late/still it is
- **THE PULSE** — a haptic "heartbeat" that isn't quite the player's own
- **BEHIND YOU** — spatial audio placing something over the player's shoulder

Notably, `LULLKit.Sensor` already has cases for `microphone`, `notifications`,
`haptics`, and `motion` — with honest rationale strings written for each —
even though only `.camera` is wired into any actual session logic today. That
reads as the allow-list having been designed ahead of the mechanics that will
use it, which fits the "horror by permission" rule: the sensor has to be
nameable and consent-gated *before* any mechanic can use it.

## The haunt server

The README describes a `server/` component, marked *(later)*:

> the Vapor **haunt server**: content that shifts between sessions, seems to
> respond, and is quietly shared between players.

There is no `server/` directory in the repo yet. The concept brief frames
this as reusing the Vapor/session/realtime stack from the MateMate chess
project, calling it "already a solved problem" — but that's a stated
intention to reuse prior work, not evidence of any LULL-specific server code
existing.

## The SpriteKit question

Whether the [Atmosphere experiment](Atmosphere-Experiment) (PR #1, draft)
gets adopted, replaced with a lighter SwiftUI/Core Animation approach, or
left as a prototype is explicitly undecided — the PR frames it as evidence to
look at, not a decision already made.

## What's genuinely open, per the project's own framing

- Whether `THE EYE` actually scares anyone (the go/no-go test the whole slice
  was built to run) — no result recorded in the repo.
- Which, if any, of the other five mechanics get built next.
- Whether the SpriteKit prototype becomes the app's rendering approach for
  ambience, or purely reactive future mechanics use it while ambience stays
  in SwiftUI.
- The haunt server — design intent only, no code.
