# Ideation — THE IDOL, and kintsugi

*Design notes, not a commitment. Exploratory — bias toward volume over polish.*

## Mood anchor

A serene idol-woman, eyes closed, skin like porcelain or marble. Hairline
fractures run across her face. Gold — kintsugi, the repair that doesn't hide
the break — seeps into the cracks instead of a repair happening off-screen.
Hydrangeas rest in her hair. She cradles a small glowing orb against her
chest, the way you'd hold something that's still breathing.

This image is a tonal reference only — not something LULL builds toward
literally or reproduces. What we take from it: **beauty quietly breaking is
the horror, not gore.** Nothing here describes or recreates the reference
image itself; everything below is original design description, in the
tradition of `docs/ideation/mirror-and-still-here.md`'s own restraint about
its reference image.

Original work throughout — no specific artwork, sculpture, or existing game
is referenced for content; the kintsugi *craft tradition* (repairing broken
pottery with gold-dusted lacquer, so the break becomes part of the object's
history rather than something hidden) is a centuries-old public art practice,
not a copyrighted work, and is used here only as a visual grammar.

## 0. Why this fits LULL

LULL's whole bet is that the phone already does this to you — a camera on
your face, watching. `THE EYE` makes that literal: something looks back.
`THE IDOL` inverts the direction without breaking the premise: instead of a
surface that watches you, it's a *held* thing — something you're asked to
look at, that changes because you keep looking. The dread isn't "it's
watching," it's "I did this by looking." That's still consent's whole shape:
the player's own attention is the mechanism, same as `THE EYE`'s camera
being the player's own choice to grant. Call the new mechanic **`THE IDOL`**,
in the tradition of `THE EYE` / `THE ROOM` / `THE REACH` / `THE MIRROR`.

## 1. Core mechanic — "the idol that cracks the longer you look"

**Escalation ladder**, mapped directly onto `EyeSession.Phase`
(`dormant → seekingConsent → watching → noticing → awake`), so it reuses the
same tested state machine and the same slow clock as everything else in
`LULLKit`:

| `EyeSession.Phase` | idol state | the feeling |
|---|---|---|
| `dormant` | nothing rendered | before anything has begun |
| `seekingConsent` | idol described, eyes closed, unbroken — consent asked plainly | a beautiful, unbroken thing, offered |
| `watching` | **clear.** Flawless porcelain, faint sheen. Establishes trust — she has to be whole first, or the cracking has nothing to depart from | calm, almost devotional |
| `watching` (later beats) | **hairline.** A single thread-thin crack, easy to miss, appears near the temple or jaw the first time the player's gaze returns to her (see §2 for "return") | "was that always there?" |
| `noticing` | **spreading.** More hairlines branch from the first — cheek, brow, the corner of a closed eye. Still no gold yet; this stage is structure breaking, not yet repair | the quiet given a shape |
| `noticing` → `awake` boundary | **gold-bleed.** Gold light begins to well up inside the existing cracks — not new damage, but the kintsugi filling what's already broken. The orb she holds brightens in step | the wound being dressed, which is worse than the wound |
| `awake` | **eyes open.** The ceiling of the ladder. Every crack now runs gold; her closed eyes open — calm, not violent, no jump-scare sting — and she is looking back through a face that is now more gold seam than porcelain | it was never asleep; it was waiting to be finished |

`awake` is the ceiling for the vertical slice, exactly as it is for `THE
EYE` and `THE MIRROR`'s "contact" stage — LULL does not go further than a
calm, open-eyed gaze back. No cracking further into ruin, no shattering, no
"her face falls apart." The gold *finishing* the damage is the scare; a
destroyed idol would be gore, which is off the table per `CLAUDE.md` §1.

**What "the longer you look" means, concretely.** Like `THE MIRROR`'s
look-away/look-back beat, this reuses `Sensor.motion` (already an allowed
sensor) to detect the phone being turned face-down, set aside, or the
player's attention breaking and returning — each *return* of attention is
what advances a crack, not raw elapsed time alone. This is a deliberate
difference from `THE EYE`'s pure clock: the idol punishes (rewards?)
*looking*, specifically, the way the mood anchor's "the longer you look"
implies. Elapsed time still gates the phase floor (same `calmSeconds` /
`noticingSeconds` shape as `EyeSession`), but a genuinely still player who
never looks away and back should see the ladder advance more slowly than one
who keeps checking on her — checking on her is the interaction, and it's
what does the damage. This wants a small extension of `EyeSession`-shaped
state (a `returns: Int` counter alongside `elapsed`), not a new subsystem —
worth a spike, not a redesign.

**Player interactions:**

- **Look, and look away.** The core loop. No swipe, no tap needed to
  progress the ladder — the phone's own screen-wake/attention signal
  (`Sensor.motion`, as above) is the whole verb, same restraint as `THE EYE`
  ("just look at your phone").
- **The panic switch still applies.** Whatever she's holding, `THE IDOL` is
  still `Sensor.camera` for the orb (see §2) and `Sensor.motion` for the
  return-detection, both already-allowed sensors — revoking consent stops
  either or both cold, same contract as `EyeSession.release()`. No mechanic
  gets an exception to `ConsentLedger`. If the player revokes mid-session,
  the idol simply stops being rendered with any live camera content — see
  §2's restraint note — not a punishment, not a "she doesn't like that,"
  just an honest stop.
- **No "fixing" the idol.** There is deliberately no wipe/repair gesture
  (unlike `THE MIRROR`'s wipe-the-glass beat) — the player cannot undo a
  crack or choose not to look. The only real choice is whether to keep
  opening the app at all, which is the same choice `THE EYE` always offers:
  close it, and it stops.

## 2. The gold orb — the eye, held

She cradles a small glowing orb against her chest. The orb *is* what `THE
EYE` is about, made an object instead of a screen: **the orb shows a
distorted, gilded version of the player's own front-camera feed**, gated by
the exact same consent flow as `THE EYE` — `CameraGate.requestAccess()`
only ever called after in-app consent, `wantsCamera` driving whether the
capture session is even running, `ConsentLedger` as the single source of
truth for whether `Sensor.camera` may be touched at all.

- **What it looks like.** Not a mirror-clear reflection (that's `THE
  MIRROR`'s register) — the orb's surface is small, curved, gold-flecked;
  the player's face reads as a warm, distorted glow inside it, more felt
  than seen. Early phases (`watching`): barely legible, mostly light.
  Later (`awake`): still never a sharp, screen-filling face — the orb stays
  small and held, the *idea* that she's holding you, not a clear video feed
  in a game about restraint.
- **She is "holding" the player.** The reading we want: not "the idol is
  possessed" but "the idol has been holding this the whole time, and now
  you can see what." This is a gentler, sadder register than `THE EYE`'s
  pure surveillance dread — closer to the mirror doc's "the gap between the
  person and what the surface insists is still there," but *tender* about
  it rather than confrontational. Restraint cuts both ways: don't let this
  curdle into something that reads as deceptive ("this is really watching
  you outside the game," per `CLAUDE.md` §1's "never actually deceive") —
  the honest rationale is on-screen before the OS prompt, exactly like
  `THE EYE`, and revoking consent make the orb visibly, immediately go
  dark/inert, not fade out ambiguously.
- **No new sensor, no new consent surface.** This is `Sensor.camera`
  wearing different art direction — it does not get its own silent
  permission or a softer-sounding rationale. If shipped, the in-app
  rationale shown before the OS prompt should say plainly that the camera
  feeds the orb's glow and nothing is saved, matching `Sensor.camera`'s
  existing rationale string in `Consent.swift` in spirit.

## 3. Kintsugi as "I AM STILL HERE," made visual

`docs/ideation/mirror-and-still-here.md` §2 treats "I AM STILL HERE" as a
**persistent utterance** — the one thing that doesn't reset when everything
else does, arriving by corrupting existing copy rather than introducing a
new voice. `THE IDOL` gives that same idea a *visual* body instead of a
textual one:

- **The gold doesn't reset.** Once a crack is filled with gold, it stays
  filled — across a return to the idol later in the same sitting, across a
  future session if `THE IDOL` is ever revisited, the way the mirror doc's
  wiped streak or scratch mark "stays" between returns (its §3). The
  cumulative gold map is small, cheap state (a `Set` of crack IDs that have
  been gilded, matching the mirror doc's "a small `Set` of applied
  decorations, not simulation") — deterministic, testable, no camera/mic
  needed to drive the *cracking* logic itself (only the orb's glow needs
  the camera).
- **The repair IS the haunting.** This is the thematic hinge: kintsugi is
  supposed to be a gentle philosophy — the break made beautiful, given
  history instead of being hidden. Here, that gentleness is what's
  unsettling: nothing is ever restored to how it was, and the "repair"
  visibly accumulates the longer the player engages, the way "I AM STILL
  HERE" accumulates rather than resolves. The idol is never made whole
  again by the gold; she is made *more finished*, and finished is the
  scary word, not broken.
- **A natural throughline, not a crossover.** This doesn't require `THE
  IDOL` and `THE MIRROR` to share a scene or a save file — the point is
  that LULL's persistence motif can recur in more than one mechanic's own
  visual grammar (a scrawled phrase in the mirror doc, gold seams here)
  without becoming a single mandatory "haunt" thread. Whether they ever
  connect for real (e.g. via the future Vapor "haunt" server, `docs/concept.md`
  §04) is an open question (§6), not a dependency.

## 4. Atmosphere, audio & cheap rendering (SwiftUI / SpriteKit, cheap-first)

**Progressive crack reveal — don't build a real fracture sim.** A small,
fixed set of hand-authored crack-line assets (SVG/vector paths converted to
masks), revealed a stage at a time as **stacked opacity-masked layers** —
each new crack is a pre-drawn asset that fades in over the previous layer,
not a physics or procedural-fracture system. This is deliberately the same
cheap-first instinct as the mirror doc's §4: canned assets for the reveal
beats, no real-time generation.

- **Gold veins** render as a second, additive-blend layer sitting *inside*
  the crack mask — a thin bloom/glow (`SpriteKit` additive blend mode, or a
  SwiftUI `Canvas` layer with `.blendMode(.plusLighter)`) so the gold reads
  as light escaping rather than paint applied. Intensity ramps as
  `noticing` → `awake` progresses, same beat-driven pacing as
  `Atmosphere.beatSeconds`.
- **The idol and hydrangeas as 2.5D parallax** — a few flat layers (idol
  torso/face, hydrangea sprigs, background) each with a small independent
  parallax offset on device tilt via `Sensor.motion`, same technique the
  mirror doc proposes for its bathroom scene (§4 there). No 3D geometry,
  no new engine — see the SwiftGodot spike's own conclusion
  (`experiments/swiftgodot/ASSESSMENT.md`) that native SwiftUI/SpriteKit
  stays the right call for LULL's current roadmap.
- **The orb** is a small circular masked view showing the (consent-gated,
  heavily distorted/gilded — §2) camera texture, composited with its own
  soft glow layer so it never reads as a clean video preview.

**Audio cues**, layered and mixed by phase (same idea as
`Atmosphere.script(for:)` mapping phase to text, but for sound):

- A soft, high, porcelain **"tick"** — not a crack/shatter sound, something
  closer to a teacup settling — timed to each new crack's reveal. Small,
  dry, almost polite.
- A **low held tone** underneath the calm phases, the audio equivalent of
  Beckett's stillness — present but not insistent, the room's own hush.
- **One true silence** in the beat immediately before the eyes open at
  `awake` — per LULL's existing restraint instinct (both the mirror doc §4
  and `Atmosphere`'s own pacing), the absence of sound scares harder than
  adding one. No sting, no chord — the tone and the ticks simply stop, and
  then the eyes are open.
- No dialogue, no gasp, no vocalization from the idol at any stage — she
  never speaks, never breathes audibly. Whatever voice governs this
  mechanic's on-screen narration (if any; see §6) stays external to her,
  the way `Atmosphere`'s registers narrate *about* the phase, never *as* a
  character.

## 5. Restraint principles (the reference image is the ceiling, not the target)

- **Dread through beauty decaying, never gore.** The reference image's
  fractures and gold are the ceiling of visual damage LULL will ever show
  here — no shattering, no "her face comes apart," no viscera-adjacent
  imagery standing in for cracked porcelain. If a crack is ever rendered
  with anything read as organic (a vein, a wound), that's over LULL's line;
  cracks stay legibly *material* — glass, ceramic, stone — never flesh.
- **The eyes opening is the ceiling, not a beginning.** `awake` is where
  the vertical slice stops, exactly as it is for `THE EYE` and `THE
  MIRROR`. No sequence where she moves, speaks, or reaches — an open gaze,
  held, is the whole payload. Escalating past that is a different, harder
  mechanic this doc explicitly does not scope.
- **Never actually deceive.** Per `CLAUDE.md` §1, the fear is *fiction and
  stays legibly fiction* — the orb never implies the player's real camera
  feed is being sent anywhere, stored, or watched by anything outside the
  session. The in-app rationale says plainly what the camera is for, same
  standard as `Sensor.camera`'s existing copy.
- **No new sensors, no new consent surface without the honest rationale.**
  `THE IDOL` is `Sensor.camera` (orb) + `Sensor.motion` (return-detection)
  wearing new art direction — nothing here gets a silent or softened
  permission ask. Consent, revocation, and the panic switch behave
  identically to `THE EYE`; `LULLKit`'s `Sensor` enum still has no case for
  anything beyond what it already permits.
- **Escalate on the same slow clock LULL already uses.** Reusing
  `EyeSession.Phase` isn't just convenient — it's the discipline. LULL
  trusts silence and slowness to do the work; `THE IDOL` earns its "eyes
  open" the same unhurried way `THE EYE` earns `awake`, not on a
  jump-scare cadence.
- **The kintsugi motif stays sincere, not clever.** It would be easy to
  make the gold-as-haunting idea feel like a gimmick or a pun. Play it
  straight: the tone throughout is closer to grief and tenderness than to
  a "gotcha" twist. The horror is that something is being *finished*
  without consent to be finished — the same shape as `THE EYE`'s dread,
  translated into an object instead of a lens.

## Open questions for later (not blocking, not answered here)

- Does `THE IDOL` ship as its own slice (own `CameraGate` wiring, own small
  state extension over `EyeSession`-shaped phases) or does it live as a
  variant "skin" inside `THE EYE`'s existing session? Leaning: own slice —
  same reasoning the mirror doc gives for `THE MIRROR` (keeps `THE EYE`'s
  scope and tests untouched), and the `returns`-counter mechanic (§1) is a
  genuine, if small, divergence from `EyeSession`'s pure-clock model that
  deserves its own tested type rather than a conditional bolted onto
  `EyeSession`.
- Does the gilded-camera-orb idea (§2) belong here, or would it fit `THE
  MIRROR` better, or both? They're not mutually exclusive — the mirror
  shows *your* reflection lying, the orb shows *her* holding you — but
  shipping both in the same vertical slice risks diluting each mechanic's
  distinct fear. Worth deciding which ships first, if either does, before
  building both.
- Should the persistent gold-crack state (§3) be purely local (one
  sitting, matching LULL's "short, one sitting" scope per `docs/concept.md`
  §05) or is this a second, independent candidate — alongside the mirror
  doc's own bathroom loop — for the future Vapor "haunt" server, where the
  gilding a *previous* player left behind might be what a new player finds?
  Both are legitimate; only the local version is small enough to prototype
  next.
- Is a `returns: Int`-driven escalation (distinct from `EyeSession`'s pure
  elapsed-time model) worth generalizing into `LULLKit` as a second
  reusable session shape, given `THE MIRROR`'s look-away/look-back beat
  wants something similar? Worth a spike before committing either mechanic
  to its own bespoke counter.
- How small does the orb's camera preview need to stay before it reads as
  "just a video call" instead of "something held"? This is a pure art
  direction/UX question that wants a prototype, not a spec, before it's
  answered here.
