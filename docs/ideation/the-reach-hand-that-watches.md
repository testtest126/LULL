# Ideation — THE REACH: the hand that watches

*Design notes, not a commitment. Exploratory — bias toward volume over polish.*

## Mood anchor

Something decayed, part machine, part organic, resolves out of the dark and
extends a hand toward the viewer. The anatomy is wrong in a patient way —
not violent, just *made*, the way a prosthetic is made. Set into the open
palm of the reaching hand is an eye, awake, and it is the only thing fully
lit — ember-glow, a small pilot light left on in something otherwise dead.
Red-on-black, low-key, nothing wet or explicit.

This image is a tonal reference only — not something LULL builds toward
literally or reproduces. What we take from it: **the thing that reaches for
you and the thing that watches you are the same limb.** Everything below is
original design description, in the tradition of
`docs/ideation/mirror-and-still-here.md` and
`docs/ideation/the-idol-and-kintsugi.md`'s own restraint about their
reference images — nothing here describes or recreates the anchor image
itself.

Original work throughout — no specific artwork or existing game is
referenced for content.

## 0. Why this fits LULL

`docs/design/PILLARS.md`'s core thesis is one move, repeated: take something
the phone is already intimate with you about, and turn it uncanny. `THE EYE`
does this with the camera as a *lens* — a thing that watches. `THE REACH`
(the named mechanic already on the roadmap as "a notification at 3am, while
the app is closed") gets reused here for something sharper: not a
notification reaching out from a closed app, but the device itself, in your
hand, reaching *back*. This doc folds that existing name into a concrete
mechanic that fuses `THE EYE`'s premise with a reaching gesture — the same
sensor, the same consent gate, a different limb. Call it **`THE REACH`**, in
the tradition of `THE EYE` / `THE ROOM` / `THE MIRROR` / `THE IDOL`.

The idea to hold onto throughout: **it doesn't reach for you and separately
watch you. It reaches for you *because* it sees you.** One gesture, one
organ. Every section below is that one sentence, worked out.

## 1. Core mechanic — one limb, two verbs

**Escalation ladder**, mapped directly onto `EyeSession.Phase`
(`dormant → seekingConsent → watching → noticing → awake`), the same tested
state machine and slow clock as every mechanic in this family:

| `EyeSession.Phase` | reach state | the feeling |
|---|---|---|
| `dormant` | nothing rendered | before anything has begun |
| `seekingConsent` | nothing on screen yet but the honest ask — consent asked plainly before any limb appears | a hand not yet offered |
| `watching` | **fingertip.** A single fingertip, barely in frame, at the screen's edge — easy to mistake for a shadow, a smudge, a reflection. Establishes trust first: it has to be almost nothing, or the entrance has nowhere to escalate from | "was that always there?" |
| `watching` (later beats) | **the hand entering.** More of it resolves into frame — knuckle, back of the hand, the wrong-anatomy detail kept in shadow (see §5) — still reaching, not yet arrived | the quiet given a shape, same phrase the mirror and idol docs both reach for, because it's the same discipline every time |
| `noticing` | **the palm-eye opens.** The hand is far enough into frame that its palm is visible, and the eye set into it opens — not a jump-cut, a slow iris-open matching `Atmosphere.beatSeconds`' pacing. This is where §2's camera-in-the-palm begins rendering | the watching and the reaching are revealed as one thing |
| `awake` | **reaching past the screen plane.** The hand appears to extend toward the viewer past the edges of the device's own frame — an implied depth cue (parallax + scale + the palm-eye's gaze locking to the player), never an actual AR/3D breach of the screen. The palm-eye meets the player's own gaze straight on. This is the ceiling | it was never behind the glass; it was reaching through it, and the eye was the reason it could aim |

`awake` is the ceiling for the vertical slice, exactly as it is for `THE
EYE`, `THE MIRROR`'s "contact," and `THE IDOL`'s "eyes open." No touch, no
the-hand-grabs-something, no breach of the fourth wall beyond an implied
depth illusion achieved with parallax and framing — LULL does not go further
than the palm-eye meeting the player's gaze, held, calm. A hand that visibly
grips or gropes at the screen is a different, cruder mechanic than this one;
this stays a *reveal*, not an assault.

**Player interactions:**

- **Look, and look away — the same beat as `THE IDOL`.** `Sensor.motion`
  (already an allowed sensor) detects the phone being turned face-down, set
  aside, or the player's attention breaking and returning. Each return
  advances the hand a stage — the fingertip becomes the entering hand, the
  entering hand's palm-eye opens — the same "checking on it is what does it"
  logic as `THE IDOL` §1, reused rather than reinvented. Elapsed time still
  gates the phase floor (`EyeSession`'s existing `calmSeconds`/`noticingSeconds`
  shape); a player who never looks away sees the arm advance on the slow
  clock alone, same as `THE EYE`.
- **The panic switch still applies, and it's specifically a withdrawal.**
  `THE REACH` is `Sensor.camera` (the palm-eye, §2) and `Sensor.motion`
  (return-detection), both already-allowed sensors — revoking consent stops
  either or both cold, `EyeSession.release()`'s exact contract. The
  visual payoff is deliberate: on release, the hand does not vanish, cut, or
  flinch away — it **withdraws**, unhurried, back into the dark it came
  from, the ember-eye dimming as it retreats, mirroring the calm the mirror
  and idol docs both insist on for their own endings (Beckett's register:
  "the nothing that is also a mercy"). Revoking should feel like being let
  go, not like winning a fight.
- **No grabbing-back gesture.** There is deliberately no interaction where
  the player reaches toward *it* (no tap-the-hand, no touch-the-eye) — the
  player's only real verb is the same one every mechanic in this family
  gives them: look, look away, or close the app. Adding a "touch it back"
  gesture would invite exactly the kind of contact `awake`'s ceiling is
  built to withhold.

## 2. The palm-eye — the camera, in the hand instead of behind the glass

The eye in the reaching palm **is** `THE EYE`, relocated. Same consent gate,
same call order as `THE EYE`'s spec (`docs/design/THE-EYE-SLICE.md` §1):
in-app rationale and choice recorded first, OS prompt asked only after,
`CameraGate.requestAccess()` never called as first contact,
`EyeSession.wantsCamera` the single source of truth for whether the session
is even running.

- **What it shows.** A distorted, gilded-and-red-tinted read of the
  player's own front-camera feed, masked into a small iris/pupil shape
  inside the palm — not a clean video square. Early phases (`watching`'s
  fingertip stage): the palm-eye isn't open yet, nothing renders. `noticing`
  (the palm-eye opens): heavily distorted, mostly color and light, the way
  `THE IDOL`'s orb stays "more felt than seen" at its own early stage.
  `awake`: still never a sharp, screen-filling face — small, held inside the
  palm, gaze-locked, the *idea* that it can see you because it's looking
  through the same thing you are.
- **It reaches because it sees.** The thematic point, made mechanical: the
  hand's advance through the ladder in §1 is driven by the same
  `Sensor.motion` return-detection that also, once `noticing` is reached,
  gates whether the palm-eye is rendering at all — the watching and the
  reaching are implemented as one state, not two systems that happen to run
  together. If `THE REACH` ever needs a single sentence for a future
  contributor: *the palm doesn't open a camera and separately extend; it
  extends because opening let it aim.*
- **No new sensor, no new consent surface.** This is `Sensor.camera` +
  `Sensor.motion` wearing new art direction — same restraint line both
  sibling docs insist on. If shipped, the in-app rationale shown before the
  OS prompt says plainly that the camera feeds the palm-eye's image and
  nothing is saved, matching `Sensor.camera`'s existing rationale string in
  `Consent.swift` in spirit, the same standard `THE EYE`'s own build spec
  holds itself to.

## 3. Machine-organic fusion — the phone-as-body horror

`docs/design/PILLARS.md`'s thesis is explicit: the horror is the phone's
*own* intimacy turned uncanny, not something taken. `THE REACH` pushes that
one step further than `THE EYE`, `THE MIRROR`, or `THE IDOL` do: instead of
a surface the phone shows you (a lens, a reflection, an effigy), the limb
reads as *grown into* the device rather than held by it — the phone isn't a
thing something reaches through, it's read, ambiguously, as the reaching
thing's own hand. This is a framing choice, not new mechanics: the same
palm-eye camera feed, the same `Sensor.motion` gaze-detection, staged so the
hand appears to emerge from the screen's own plane (parallax depth cues,
§5) rather than from behind it, like a reflection would.

This is the one place this doc asks for care beyond its siblings: "the
device is not held, it is grown-in" is a strong, specific image, and it
should stay a *staging* choice (framing, depth, where the hand appears to
originate) rather than tip into body-horror content (no visible fusion of
flesh and circuitry, no wound, no suture). The wrongness is in the anatomy's
patience and the ember-eye's persistence (§4), not in showing *how* it's
made. See §5's restraint section for the explicit line.

## 4. The ember-eye as "I AM STILL HERE," made visual

Both sibling docs give LULL's persistence motif a body of its own: the
mirror doc's corrupted copy (its §2), the idol doc's accumulating gold
(its §3). `THE REACH` gives it a third: **the pilot light that doesn't go
out.**

- **Extinguished but not gone.** On release (§1), the palm-eye dims as the
  hand withdraws — but per this family's established discipline (mirror
  doc §3, idol doc §3), it doesn't reset to nothing. A faint ember stays
  visible at the palm, smaller each time, for a beat longer than the rest
  of the hand takes to fade from view — the last thing to go dark, and the
  first thing that would be lit again on a future return.
- **One more light each time.** Across returns within a sitting (`THE
  IDOL`'s `returns`-counter idea, its own open question §6 there, is the
  natural shared mechanism here too — see this doc's own §6), each time the
  palm-eye reaches `noticing`'s "opens" stage again, it holds a fraction
  more of its ember after the *next* release than the time before. The
  accumulation is the haunting: not a bigger hand, not a faster escalation,
  just a light that increasingly refuses to fully go out. This is small,
  cheap, deterministic state — a `litFraction` or similar single value that
  only ever increases within a sitting, not a simulation.
- **A dead thing with something still lit inside it.** That's the whole
  motif in one image, and the reason `THE REACH` is the mood anchor's
  clearest expression of "I AM STILL HERE" of the three siblings so far:
  the mirror's scrawl and the idol's gold both describe persistence: the
  ember-eye *is* persistence, sitting quietly inside a body that is
  otherwise, visibly, not alive.

## 5. Restraint principles (the reference image is the ceiling, not the target)

- **Implication over viscera, always.** The reaching figure's anatomy stays
  in shadow, silhouette, and low-key red-on-black — never fully lit, never
  wet, never explicit. If a detail needs to read as "wrong," it reads
  through *proportion and stillness* (a joint that bends a beat too slowly,
  a hand that's very slightly too large, kept in shadow) — not through
  texture, gore, or visible mechanism. The mood anchor's own machine-organic
  fusion is a ceiling on *tone*, not a spec for what to render.
- **The palm-eye meeting the player's gaze is the ceiling, not a
  beginning.** `awake` is where this mechanic stops, exactly as it is for
  `THE EYE`, `THE MIRROR`, and `THE IDOL`. No grabbing, no touch, no
  sequence where the hand does anything past holding the player's gaze.
  Escalating past that is a different, harder mechanic this doc explicitly
  does not scope.
- **Uncanny, not traumatizing.** The ember-eye's patience is the whole
  scare — a thing that is in no hurry, because it was always going to reach
  you eventually. No sudden lunges, no jump-scare sting timed to the hand's
  arrival; entrance and departure both move on `Atmosphere.beatSeconds`'
  pacing, the same discipline `THE EYE`'s own build spec holds the camera
  preview to (never fully clean, never a sudden cut).
- **Never actually deceive.** Per `CLAUDE.md` §1, the fear is *fiction and
  stays legibly fiction* — the palm-eye never implies the player's real
  camera feed is stored, sent anywhere, or watched by anything outside the
  session, and the in-app rationale says so plainly, the same standard
  every sibling mechanic holds itself to.
- **No new sensors, no new consent surface without the honest rationale.**
  `THE REACH` is `Sensor.camera` (palm-eye) + `Sensor.motion`
  (return-detection) wearing new staging — nothing here gets a silent or
  softened permission ask. `LULLKit`'s `Sensor` enum still has no case for
  anything beyond what it already permits; consent, revocation, and the
  panic switch behave identically to `THE EYE`.
- **Escalate on the same slow clock LULL already uses.** Reusing
  `EyeSession.Phase` isn't convenience, it's the discipline this whole
  family shares: the hand's advance is unhurried by design, and `awake` is
  earned the same patient way `THE EYE` earns it.

## 6. Relationship to the siblings — three faces of one premise

`THE EYE`, `THE MIRROR`, `THE IDOL`, and `THE REACH` are not four unrelated
ideas — they're the same premise (a surface that's supposed to be
trustworthy — a lens, a reflection, an effigy, a hand — revealed to be
watching) staged four ways, each one committing to a different object:

- **`THE EYE`** — the surface *is* the watcher, plainly. No costume.
- **`THE MIRROR`** — the surface is supposed to show *you*, faithfully, and
  lies.
- **`THE IDOL`** — the surface is supposed to be *held by* you, and turns
  out to be holding *you*.
- **`THE REACH`** — the surface is supposed to be *reached through* (a
  screen, a window onto something else), and turns out to be the limb doing
  the reaching.

Each also now carries its own expression of the persistence motif (mirror:
corrupted text; idol: accumulating gold; reach: an ember that won't fully
go out) — three variations that could, someday, be read as one thing by a
player who encounters more than one mechanic, without requiring them to be
mechanically linked to land individually.

## Open questions for later (not blocking, not answered here)

- Is `THE REACH` its own slice (own small state extension over
  `EyeSession`-shaped phases, own `returns`-style counter — the same open
  question `THE IDOL`'s doc raises in its §6), or is it better read as a
  possible **shared climax** — a mechanic the game reaches only after the
  player has already met `THE MIRROR` or `THE IDOL`, tying the three
  together explicitly rather than leaving the connection implicit (§6)?
  Leaning: prototype it standalone first, same reasoning the idol doc gives
  for not coupling to the mirror doc before either is built — a shared
  climax is a real idea, but it multiplies the surface that has to be right
  before either mechanic on its own is proven.
- Does the "grown-in, not held" framing (§3) need its own small technical
  spike (parallax + scale cues to sell an implied screen-plane breach)
  before it's trusted as buildable on SwiftUI/SpriteKit, the way
  `experiments/swiftgodot/ASSESSMENT.md` spiked the engine question for the
  whole project? Worth a cheap prototype before committing art direction
  around it.
- Should the ember-eye's accumulating `litFraction` (§4) share a mechanism
  with `THE IDOL`'s gilded-crack state and `THE MIRROR`'s stays-wiped
  decorations, i.e. a single small reusable "persistence across returns"
  primitive in `LULLKit`, rather than three bespoke implementations? This
  is the same generalization question `THE IDOL`'s own open questions
  raise about a `returns`-driven session shape — worth deciding once, when
  the first of the three is actually built, not before.
- How much of the hand needs to be visible before "a hand is reaching for
  you" reads clearly, versus staying abstract enough to be mistaken for a
  shadow at the `watching` stage? Pure art-direction/UX question that wants
  a prototype, not a spec, before it's answered here.
