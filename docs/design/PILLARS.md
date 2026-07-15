# LULL — Design Pillars

*A consolidation, not new design. Everything here already exists in
`CLAUDE.md`, `README.md`, `docs/concept.md`, `LULLKit`, the ideation docs, and
the SwiftGodot spike — this doc is where they're read together. See
[`ROADMAP.md`](../../ROADMAP.md) for what's next.*

## The core thesis

**Not "a scary game on a phone" — the scary thing is the phone.** It is in
your hand, it has a camera on your face and a mic in your room, it knows it
is late, and it can reach you after you have closed it. Every mechanic in
this document is a variation on one move: take something the phone is
*already* intimate with you about — your face, your voice, your stillness,
your attention — and turn it uncanny. The dread comes from what the player
*knowingly* hands the device, not from anything taken. That's the whole
difference between this game and a violation.

## Pillar 1 — horror by permission

Non-negotiable, and everything below defers to it (`CLAUDE.md` §1):

- **Consent is explicit, explained, and revocable**, per sensor. Default is
  deny. The player always has a panic switch that revokes everything at
  once, instantly — `ConsentLedger.revokeAll()`.
- **Forbidden, forever, not "not yet."** Photos, contacts, location trails,
  health data, and anything read without the player knowing. `LULLKit`'s
  `Sensor` enum has no case for them — code that wanted to reach a forbidden
  sensor cannot even name one. Right now the whole allow-list is five cases:
  `camera`, `microphone`, `notifications`, `haptics`, `motion`
  (`Consent.swift`).
- **No genuine harm.** Uncanny, not traumatizing. Dread over gore — the
  phone doesn't need blood, and restraint scares harder than spectacle for a
  build this size.
- **Never actually deceive.** The fear is fiction and stays legibly fiction —
  no fake "your data has leaked," no implying real capture or exfiltration.
  The *game* can lie to its own fiction (an idol that was never asleep); LULL
  never lies to the player about what the app itself is doing.
- **No PII in the repo, logs, or telemetry.** Ever.

If a scare can only work by breaking this, the scare is wrong, not the rule.
This is enforced in the type system, not just policy — `CameraGate.requestAccess()`
is only ever called after in-app consent and the honest rationale, never as
first contact with the OS prompt, and `EyeSession.release()` is the panic
switch made concrete: honored from any phase, at any time.

## Pillar 2 — the mechanic taxonomy

One fear mechanic, executed flawlessly, beats six built shallowly. `THE EYE`
is the spine — the only one implemented in `LULLKit`/`app/` today
(`EyeSession`, `CameraGate`, the SwiftUI/AVFoundation app). The rest are
named and scoped, at varying stages from "shipped mechanic" to "one paragraph
in `docs/concept.md`" to "a full ideation doc." Each one is the same thesis,
aimed at a different sense the phone already has access to:

| mechanic | sensor / signal | status | the device turned against you |
|---|---|---|---|
| **`THE EYE`** | `Sensor.camera` | **shipped** (v0.1 vertical slice) | the front camera watches the player, calm at first, and reacts to being watched back |
| **`THE ROOM`** | `Sensor.microphone` | named (`docs/concept.md`) | the microphone hears the silence, and what breaks it |
| **`THE REACH`** | `Sensor.notifications` | named (`docs/concept.md`) | a notification at 3am, while the app is closed — it knows you left |
| **`THE HOUR`** | ambient (time + `Sensor.motion` stillness) | named (`docs/concept.md`) | it plays differently when it is late and the room has gone still |
| **`THE PULSE`** | `Sensor.haptics` | named (`docs/concept.md`) | a heartbeat in your palm, through haptics, that is not quite yours |
| **`BEHIND YOU`** | spatial audio | named (`docs/concept.md`) | something placed just over your shoulder, in sound alone |
| **`THE MIRROR`** | `Sensor.camera` + `Sensor.motion` | ideation (`docs/ideation/mirror-and-still-here.md`, PR #4, merged) | a reflection that stops matching — lag, drift, independence, contact — the horror of a surface that's supposed to be faithful, lying |
| **`THE IDOL`** | `Sensor.camera` + `Sensor.motion` | ideation (`docs/ideation/the-idol-and-kintsugi.md`, PR #7) | a still, beautiful effigy that fractures a little more each time the player's gaze returns to it; the gold orb she holds is a distorted, gilded read of the player's own camera feed — she is holding you |

Every named mechanic maps to a sensor already on the `Sensor` allow-list.
None of the ideation mechanics introduce a new sensor or a softer consent
path — `THE MIRROR` and `THE IDOL` are explicit about reusing `CameraGate`/
`ConsentLedger` exactly as `THE EYE` does, panic switch included. That's the
taxonomy's real discipline: new mechanics are new *readings* of an
already-granted sensor, never a reason to ask for a new one.

## Pillar 3 — the voice

LULL narrates in literary registers, layered over `EyeSession.Phase`
(`dormant → seekingConsent → watching → noticing → awake`, plus the two
endings `denied`/`released`) so the writing is provable and pure — the
`Atmosphere` layer touches no sensor and can never widen what the game is
permitted to do (`Atmosphere.swift`).

- **Kafka — the threshold.** Governs `seekingConsent`: a record opening in
  your name, a verdict withheld. You have done nothing; that was never the
  question.
- **Beckett — the lull.** Governs `watching`'s calm and both endings
  (`denied`, `released`): waiting, the failing light, the nothing that is
  also a mercy. Saying no is always safe here.
- **Poe — the watch.** Governs the escalation through `noticing` into
  `awake`: the eye that will not blink, the heart beneath the floor that
  will not stop.
- **Bulgakov — the guest** *(landing via PR #5, not yet merged)*. An urbane,
  amused devil-as-observer throughline that doesn't own a single act — it
  runs *alongside* whichever register owns the moment, present as an aside in
  the threshold, the lull, and the watch. Hospitable at `seekingConsent`
  ("do come in, we've been expecting you"), curdling by `awake` into
  revealing he was never a guest at all. Its signature motif — *manuscripts
  don't burn* — is the throughline's own persistence claim.

Every line is original prose written *in* each register, never a quotation —
this is a design language, not a citation, and no author's name ever appears
on screen to break the spell.

**"I AM STILL HERE" — the persistence motif.** First named in the mirror
ideation doc as the one utterance that survives when everything else resets:
a corruption threaded into existing `awake`-phase copy rather than a new
voice of its own, arriving by *infecting* what's already on screen. `THE
IDOL`'s kintsugi gives the same idea a visual body instead of a textual one —
gilded cracks that accumulate and never reset, so "the repair" *is* the
haunting. Bulgakov's "manuscripts don't burn" is the same claim again, a
third time, in a third register: this project has one thesis about
persistence, expressed three ways, on purpose — not three unrelated ideas.

Escalation itself is always paced by the same slow instinct: `Atmosphere.beatSeconds`
(9 seconds a line) and `EyeSession`'s `calmSeconds`/`noticingSeconds`
(40s / 30s in the shipped slice) exist because LULL trusts silence over a
jump-scare cadence. Every ideation mechanic explicitly commits to escalating
on this same clock rather than inventing its own tempo.

## Pillar 4 — native first

Evaluated directly, not assumed: `experiments/swiftgodot/ASSESSMENT.md`
(PR #6) spiked SwiftGodot (Swift bindings for Godot 4.6) as a possible engine
layer and recommends against adopting it for the current roadmap. In short —
a 34MB engine dependency, a build cost two to three orders of magnitude
heavier than `LULLKit`'s sub-second build, no ready-made bridge from
`AVCaptureSession`/microphone capture into Godot despite `GodotApplePlugins`,
and a consent boundary that would have to cross Swift → GDExtension → engine
instead of staying inside one pure, instantly-testable Swift type. LULL's
leverage is the phone's sensors plus the type-enforced consent core, not 3D
fidelity — SwiftUI/SpriteKit already deliver that.

**Decision: stay native (SwiftUI + SpriteKit + AVFoundation) for `THE EYE`
and every mechanic currently scoped**, including `THE MIRROR` and `THE
IDOL` — both ideation docs already commit to cheap-first native rendering
(opacity-masked layers, additive-blend glow, 2.5D parallax via device tilt,
no fracture sim, no new engine). Revisit SwiftGodot only if LULL commits to
real 3D fidelity SpriteKit/Canvas genuinely can't sell — and even then, only
as a strict hybrid where Godot owns rendering and `LULLKit` remains the sole,
unmodified gatekeeper for every sensor; never `SwiftGodotKit`-drives-the-app,
which would widen the consent boundary for engine convenience.

## Pillar 5 — build sequence

The whole bet, in one question, repeated at every stage: **does it make one
person, alone at night, put the phone face-down?** If yes, the next mechanic
is worth building. If no, it was cheap to learn that here.

1. **`THE EYE` — done.** The vertical slice: consent flow, `CameraGate`,
   `EyeSession`'s phase machine, the Kafka/Beckett/Poe voice (Bulgakov
   landing). Provable in about a week; it is the spine everything else hangs
   off, and the pattern every later mechanic reuses — a sensor gated by
   `ConsentLedger`, a small phase machine, a voice layered on top that
   touches nothing.
2. **A second beat — `THE MIRROR` or `THE IDOL`, not both at once.** Both
   ideation docs already flag the risk of shipping two camera-driven
   mechanics in one sitting diluting each one's distinct fear (see each
   doc's own open questions). Whichever ships second should be picked, not
   built in parallel — the current `ROADMAP.md` "Now" leaves that pick open.
3. **The remaining named mechanics** (`THE ROOM`, `THE REACH`, `THE HOUR`,
   `THE PULSE`, `BEHIND YOU`) — each is a new sensor reading using the same
   established pattern (gate → phase machine → voice), not a new
   architecture. Sequencing among them is undecided; each is currently only
   a paragraph in `docs/concept.md`.
4. **The "haunt" Vapor server — later, and gated.** Cross-session
   persistence (a haunt genuinely *shared* between players, per
   `docs/concept.md` §04) is the first piece of LULL that talks to a network
   at all. That's also precisely where the chess project's security rigor —
   left behind everywhere else per `CLAUDE.md`'s "keep the rigor, drop the
   ritual" — comes back: a server handling any player data earns real
   security gating the client-only mechanics above don't need. Both
   `docs/ideation/mirror-and-still-here.md` and
   `docs/ideation/the-idol-and-kintsugi.md` flag the haunt server as a
   plausible home for their own persistence motifs, but neither depends on
   it — the local, one-sitting version of each is what's buildable next.
