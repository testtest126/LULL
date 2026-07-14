# Ideation — the mirror, and "I AM STILL HERE"

*Design notes, not a commitment. Exploratory — bias toward volume over polish.*

## Mood anchor

A dim, filthy bathroom. A woman's back is to us; she faces a grimy,
blood-streaked mirror. Her reflection does not match her — gaunt, hollow-eyed,
wet stringy hair, mouth stretched in a scream, skin cracked and bloodied.
Scrawled across the glass: **"I AM STILL HERE."** Pentagram scratches gouged
into the wall. A rusted faucet, a blood-spattered sink, one sickly light.

This image is a tonal reference only — not something LULL builds toward
literally or reproduces. It is far past LULL's line (see `CLAUDE.md` §1:
*uncanny, not traumatizing*). What we take from it: **the gap between the
person and what the mirror insists is still there.** Everything below is about
building toward that gap slowly, and stopping well short of the image itself.

Original work throughout — no P.T., no other existing game is referenced for
content, only for the general shape of "a loop that remembers."

## 0. Why this fits LULL

LULL's whole bet is that the phone already does this to you — a camera on
your face, a mic in your room. A mirror is the oldest version of the same
idea: a surface that is supposed to show you yourself, faithfully, and the
horror of it lying. It's `THE EYE`'s premise wearing a different costume, and
it can reuse `THE EYE`'s actual plumbing (see §3). Call the new mechanic
**`THE MIRROR`**, in the tradition of `THE EYE` / `THE ROOM` / `THE REACH`.

## 1. Core mechanic ideas — "the reflection that doesn't match"

**Escalation ladder** (mirrors `EyeSession.Phase`'s `dormant → seekingConsent →
watching → noticing → awake`, so it can reuse the same state-machine shape):

1. **Clear.** The reflection tracks the player normally. Establishes trust —
   this has to be boring first, or the divergence has nothing to depart from.
2. **Lag.** The reflection is a beat behind. A half-second at first, easy to
   mistake for a frame hitch. Grows across the session.
3. **Drift.** The reflection stops matching *exactly* — a held pose the
   player already broke, a hand still raised. Still deniable.
4. **Independence.** The reflection does something the player didn't do:
   blinks out of sync, turns its head fractionally, mouths something. The
   first true rule break.
5. **Contact.** The reflection writes on the glass — see §2. This is the
   ceiling. LULL does not go further than this in the vertical slice.

**Player interactions:**

- **Look away / look back.** Using `Sensor.motion` (already an allowed
  sensor) to detect the phone being turned face-down or the player's gaze
  breaking — the reflection is caught mid-change when the player looks back,
  Polaroid-style: not a jump-scare sting, a "wait, was it like that before?"
  The horror is the player's own uncertainty, not a loud reveal.
- **Wipe the mirror.** A drag gesture across the screen to clear condensation
  or grime — the classic "cleaning it makes it worse" beat. Wiping should
  *increase* clarity of the wrong thing, never reveal a jump-scare on
  contact. Early wipes reveal mundane grime; later wipes reveal detail the
  player didn't ask for. This is the one interaction that is pure UI (no
  sensor), so it's cheap to build and safe to iterate on first.
- **Avoid mirrors.** Some rooms should let the player route around looking
  entirely (walk past, keep the phone pointed elsewhere). This isn't a fail
  state — per `CLAUDE.md` §1, the player needs an equivalent of the panic
  switch *within the fiction*, not just the meta-level "close the eye"
  button. Avoidance should be a legible, always-available choice, not a
  trap disguised as one.
- **The panic switch still applies.** However dressed up, `THE MIRROR` is
  still `Sensor.camera` under the hood (see §3) — revoking consent stops it
  cold, same contract as `EyeSession.release()`. No mechanic gets an
  exception to `ConsentLedger`.

## 2. The "I AM STILL HERE" motif

Treat this as a **persistent utterance**, not a jump-scare line — the one
thing in the session that does not reset when everything else does.

- **Where it lives.** In the current three-register voice
  (`LULLKit/Sources/LULLKit/Atmosphere.swift`), this doesn't need a fourth
  author-register — that would dilute Kafka/Beckett/Poe's discipline. Instead
  it's a **corruption of the Poe lines already in `awake`**: the same
  narration the player has been reading, but with words swapped out or
  overwritten, as if something is editing the game's own text mid-sentence.
  E.g. `"it knows your face now."` degrading, over repeat visits, toward
  `"it knows your face now. i am still here."` — the motif arrives by
  *infecting* existing copy, not by introducing a new voice.
- **Persistence across resets.** If the session (or a future multi-room
  build) has any reset/loop point, this line is the one thing that survives
  it — appearing a beat earlier each loop, in a slightly different place
  (mirror, then a fogged window, then a lockscreen notification via
  `THE REACH`). This is a natural bridge to the "haunt" server concept in
  `docs/concept.md` §04 — the line could plausibly be something *shared*
  across sessions server-side later (other players saw this too, tonight),
  though that's beyond the vertical slice and shouldn't block it.
- **Restraint on the phrase itself.** It should mostly be heard or implied,
  not shown in full, blood-scrawled glory, every time. Prefer: fogged and
  fading before it's fully legible; half-wiped away by the player's own
  wipe gesture; spoken once, low, by the ambient audio layer instead of
  written. Reserve the full visual scrawl (if it appears at all) for a single
  moment near the ceiling of the escalation ladder, not a running motif.

## 3. The bathroom as a recurring space (escalating decay)

For a first pass, treat "recurring" as *within one sitting* — matching
LULL's existing "short, one sitting" scope (`docs/concept.md` §05), not a
multi-session structural rework. A believable minimal loop: the player
leaves the bathroom (hallway beat, a few seconds) and returns to it — 3–5
times over the session, each time seeded from `EyeSession.elapsed` /
`Atmosphere.beat(forElapsed:)` so the escalation is driven by the same clock
already in `LULLKit`, not a bespoke timer.

Concrete, buildable deltas per return (small enough to be a config table, not
new art each time):

| return # | mirror state | room state | audio delta |
|---|---|---|---|
| 1 | clear, faint condensation | light steady | faucet drip, slow |
| 2 | condensation thicker, one streak wiped from before stays wiped | light flickers once | drip quickens; a breath under it |
| 3 | reflection lag begins | a wall scratch mark appears, small | breathing audible, not synced to player |
| 4 | reflection drift; a handprint on the glass that isn't the player's | second scratch mark, light dims a stage | the "I AM STILL HERE" motif's first partial appearance |
| 5 (ceiling) | independence beat; glass shows a word starting to form | light nearly gone, single bulb sway | motif at its clearest, still not fully legible |

Everything that "stays" between returns (a wiped streak, a scratch mark) is
state the app already has to track cheaply — a small `Set` of applied
decorations, not simulation. This keeps it in the spirit of `EyeSession`:
deterministic, testable, no camera/mic needed to drive it.

## 4. Atmosphere & tech notes (SwiftUI / SpriteKit, cheap-first)

**Reflection rendering — don't build a real mirror.** Two cheap options,
usable together:

- **Live-feed distortion (reuses `THE EYE` plumbing directly).** The
  `CameraGate` protocol already exists and is consent-gated. Feed the front
  camera through `CIFilter`s (desaturate, contrast crush, slight
  chromatic-aberration/CIColorMatrix) and a **frame-delay ring buffer** for
  the "lag" beat — hold the last N frames and display frame `now - k`, where
  `k` grows with `elapsed`. This alone produces "reflection is a half-second
  behind" for free, with no per-frame ML or face tracking required.
- **Canned-asset cut-ins for the "reveal" beats.** For anything past
  "drift" (independence, contact), don't try to render a generated distorted
  face in real time — crossfade from the live distorted feed to a
  pre-authored short video/image asset at the moment the player looks back
  (the classic misdirection: they were told the reflection looked normal
  half a second ago; cut to the asset while attention was elsewhere). This
  keeps the expensive/creepy part fully authored and controllable, and
  avoids uncanny-valley live-generation problems entirely.
- No 3D bathroom geometry. A 2.5D layered scene (a few SwiftUI `Canvas` /
  SpriteKit `SKSpriteNode` layers — back wall, mirror frame, sink, light —
  each with a small independent parallax offset on device tilt via
  `Sensor.motion`) reads as a real space for a fraction of the build cost.

**Lighting.** Single sickly source: a `RadialGradient` centered near the
light fixture, desaturated warm-to-dim, composited under a dark vignette.
Flicker as opacity jitter on a `Timer`, reusing the cadence feel of
`Atmosphere.beatSeconds` (a slow, held breath, not a strobe — LULL is dread,
not a seizure risk).

**Audio cues** (layered, looping stems, mixed by phase — same idea as
`Atmosphere.script(for:)` mapping phase to content, but for sound instead of
text):
- Dripping faucet — steady loop, tempo/pitch nudges up with `elapsed`.
- Breathing — starts *desynced* from the player's own breathing/stillness
  (detectable via `Sensor.motion` stillness, same signal `THE HOUR` already
  wants), which is the unsettling part: it's a breathing sound that is very
  obviously not keeping the player's time.
- The "scrawl" sound — a low scratch/screech, only ever timed to accompany
  the motif's letters appearing on the glass (see §2), never used
  standalone as a cheap sting.
- Reserve one true silence beat right before the ceiling escalation — per
  LULL's existing restraint instinct, the absence of the loop stems is
  scarier than adding a new one.

**Haptics.** Reuse `THE PULSE` mechanic rather than invent a new one: the
heartbeat already quickens with dread state elsewhere in the design; let the
mirror's escalation ladder drive the same haptic curve so the phone in the
player's hand and the thing in the glass are legibly the same threat.

## 5. Restraint principles (the reference image is the ceiling, not the target)

- **Dread over gore, always.** No blood-streaked anything as a baseline
  state. If blood appears at all, it's a single small, ambiguous mark late
  in the ladder — never the sink/wall/mirror soaked as in the reference.
- **Implication over reveal.** The revenant reflection, if it appears at
  all, is glimpsed partially — peripheral, motion-blurred, cut short by the
  player's own flinch (camera/attention model), or by the app itself cutting
  to black. A screen-filling clear shot of a screaming face is the reference
  image's register, not LULL's — LULL earns dread through withholding, per
  the whole voice/`Atmosphere` design.
- **Escalate on the same slow clock LULL already uses.** `Atmosphere`'s
  9-second beat and `EyeSession`'s 40s calm / 30s noticing pacing exist
  because LULL trusts silence to do the work. `THE MIRROR` should escalate
  on a comparably slow clock, not a jump-scare cadence.
- **Never actually deceive.** Per `CLAUDE.md` §1, the fear is *fiction and
  stays legibly fiction* — no fake "this is a real recording," no implying
  real data was captured or leaked. The reflection lies to the character;
  LULL never lies to the player about what the game is.
- **No new sensors, no new consent surface without the honest rationale.**
  `THE MIRROR` is `Sensor.camera` (+ optionally `Sensor.motion` for the
  parallax/look-away beats) wearing a costume — it does not get its own
  silent permission. The in-app rationale should say plainly that the
  camera is used to render a distorted reflection, and that nothing is
  saved. Consent, revocation, and the panic switch behave identically to
  `THE EYE`.
- **The motif stays a motif.** "I AM STILL HERE" is most effective
  under-shown. Resist the urge to cash it in early or often — it should
  read as *encroaching*, one incomplete appearance at a time, not as a set
  piece repeated verbatim.

## Open questions for later (not blocking, not answered here)

- Does `THE MIRROR` ship as part of the `THE EYE` vertical slice, or as its
  own slice reusing `CameraGate`? (Leaning: own slice — keeps `THE EYE`'s
  scope, and its existing tests, untouched.)
- Is the bathroom loop scoped to one sitting (§3, recommended) or does it
  become the first real use of the future Vapor "haunt" server for
  cross-session persistence? Both are legitimate; only the first is small
  enough to prototype next.
- Should the corrupted-Poe-line approach in §2 live in `Atmosphere.swift`
  directly (a `corrupted(_:)` transform over existing `Line`s) or as a
  parallel script keyed by loop count? The former keeps one source of
  truth for copy; worth a spike before committing.
