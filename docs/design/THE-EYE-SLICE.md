# Build spec — `THE EYE` vertical slice

*A spec, not new design. `THE EYE` is already implemented (`LULLKit` +
`app/`, README's "v0.1 — the vertical slice") — this document is the
canonical, buildable spec it satisfies: what's in scope, the exact contract
of each piece, acceptance criteria, and the test plan. Useful as a regression
baseline today, and as the template shape for `THE MIRROR` / `THE IDOL`'s own
specs later (see [`PILLARS.md`](PILLARS.md) pillar 5). Grounded in the real
types — `EyeSession`, `CameraGate`, `ConsentLedger`, `Atmosphere` — not
invented ones.*

## Scope

**One ~5-minute sitting, alone, in the dark, on one device, no network.**
That's the whole slice.

### In
- The in-app consent step (`ConsentView`) → OS permission → the camera
  opening (`EyeSession.watching`) → escalation (`noticing` → `awake`) → an
  ending (`denied` or `released`).
- `EyeSession`'s phase machine exactly as implemented, driven by a real
  clock (`GameModel.startClock()`).
- `CameraGate`/`CameraController`: front camera only, on-device only,
  gated by `ConsentLedger`.
- The `Atmosphere` voice: Kafka, Beckett, Poe (Bulgakov joins as a fourth
  register per PR #5 — this spec covers the flow either way; see §6).
- The panic switch (`closeTheEye()`), available from every phase that has a
  camera open.

### Out (explicitly deferred elsewhere)
- **`THE MIRROR`** and **`THE IDOL`** — separate mechanics, separate specs,
  per `PILLARS.md` pillar 5. Nothing here should be extended in place to grow
  either of them.
- **The haunt Vapor server** — this slice has no network calls and no
  cross-session state. `EyeSession` does not persist between app launches.
- **Any sensor beyond `Sensor.camera`.** `THE ROOM` (mic), `THE REACH`
  (notifications), `THE HOUR`, `THE PULSE` (haptics) are not part of this
  slice. `Sensor.motion` is not used here either — that's `THE MIRROR`/`THE
  IDOL`'s addition.
- **Multi-session / return visits.** One sitting, start to finish, no
  "resume where you left off."

## 1. The consent flow, start to finish

Three layers, in this order, and never reordered:

1. **In-app rationale, before any OS prompt** (`ConsentView`, shown on
   `.dormant`/`.seekingConsent`). Plain language, on screen:
   - `Sensor.camera.rationale`: *"So LULL can see your face in the dark. You
     can turn this off at any time."*
   - An explicit no-surveillance line: *"Nothing is recorded. Nothing leaves
     your phone. You can close the eye at any time."*
   - A faint Kafka epigraph (`Atmosphere.narration(for: .seekingConsent)`) is
     shown *alongside* this copy, never in place of it — atmosphere is
     additive, the honest copy is never touched by the voice layer.
   - Two choices, both real, both terminal-safe: **"Let it watch"** and
     **"Not tonight."** `ConsentView.onAppear` calls `GameModel.begin()`,
     which is the only thing that moves `EyeSession` from `.dormant` to
     `.seekingConsent` — nothing happens before the player sees this screen.
2. **The in-fiction decision, recorded first.** Tapping "Let it watch" calls
   `GameModel.allowTheEye()`, which calls `consent.grant(.camera)`
   *before* asking the OS — the player's own in-app yes is what's recorded
   as consent, not the OS dialog's outcome alone.
3. **The OS permission, asked last, never as first contact.**
   `CameraController.requestAccess()` wraps
   `AVCaptureDevice.requestAccess(for: .video)`. Two ways this can still say
   no:
   - **OS denies or was previously denied at the system level.** `allowTheEye()`
     immediately calls `consent.revoke(.camera)` and `eye.consent(false)` —
     the in-app grant is walked back the instant the OS says no. The session
     lands on `.denied`, identical in outcome to the player choosing "Not
     tonight" in-app.
   - **Player taps "Not tonight."** `GameModel.declineTheEye()` calls
     `eye.consent(false)` directly — the OS prompt is never shown at all.

### The denial path is a real ending, not a dead end

`EyeSession.Phase.denied` is terminal (`EyeSessionTests.testDenialIsRespectedAndTerminal`
pins this: `eye.advance(by: 1000)` after denial does not move the phase).
`RootView` routes `.denied` to `EndingView`, showing
`Atmosphere.narration(for: .denied)`: *"you said no. nothing was written
down. sleep well."* No guilt trip, no re-ask, no degraded "consolation"
experience — declining is a complete, safe, and equally-weighted ending to
the sitting, not a worse one.

## 2. The panic switch

`GameModel.closeTheEye()` — reachable from `EyeView`'s "close the eye"
control, visible on every frame once `.watching`/`.noticing`/`.awake` has
started. Its guarantees, in order:

1. **Stops the clock first.** `clock?.cancel()` — no more phase advancement
   can happen after this call starts.
2. **Releases the phase machine.** `eye.release()` sets `phase = .released`
   from *any* phase (`EyeSessionTests.testReleaseClosesTheEyeFromAnyPhase`
   exercises this from `.seekingConsent`, `.watching`, and deep into
   `.watching` after a long `advance`) — there is no phase this can fail
   to interrupt.
3. **Revokes everything, not just the camera.** `consent.revokeAll()` — the
   full panic switch, not a scoped revoke, even though only `.camera` is
   granted in this slice. This is deliberate: the panic switch's contract is
   "everything, always," not "whatever this mechanic happened to be using."
4. **Stops the camera at once.** `camera.stop()` calls
   `session.stopRunning()` — no frame is captured after release is called.
   `eye.wantsCamera` is `false` the instant `phase == .released`, and the
   app never asks the question "should the camera be running" any other way
   — `EyeView`'s camera preview is bound to `model.camera.session`, which is
   already stopped by the time `.released` routes away from `EyeView`.
5. **Returns to safety.** `RootView` routes `.released` to `EndingView`
   showing `Atmosphere.narration(for: .released)`: *"the eye is closed.
   nothing watches now. it was only a game."*

**Guarantee this slice must hold:** there is no reachable state, once the
camera has ever opened, from which the panic switch does not stop it. This
is the one behavior every acceptance pass (§7) checks first.

## 3. The core loop

`EyeSession.Phase`: `dormant → seekingConsent → {denied | watching →
noticing → awake} → released` (released reachable from `watching`,
`noticing`, or `awake`).

Driven by `GameModel.startClock()`: a 0.5-second `Timer`, each tick calling
`eye.advance(by: dt)` with the real elapsed wall-clock delta. `EyeSession.advance`
clamps `dt` to at most 5 seconds per call — a backgrounded app cannot
fast-forward the horror on return (`EyeSessionTests.testBackgroundingCannotFastForwardTheHorror`).
The clock cancels itself once `eye.wantsCamera` goes false (release, or —
not reachable in this slice — a phase with no camera need).

| phase | what the player sees | what the player hears | ends when |
|---|---|---|---|
| `watching` | `CameraPreview`, desaturated, heavily blurred (`radius: 4`), low opacity (`0.22`), a strong dark vignette (`0.55`) | Beckett lines, one per `Atmosphere.beatSeconds` (9s): *"close your eyes. let it watch for you."* → *"the light is going. let it go."* | `elapsed >= calmSeconds` (40s in the shipped slice) |
| `noticing` | same preview, less blurred, opacity `0.5`, vignette eases to `0.32` | Poe lines begin: *"you're still awake. so is it."* → *"something behind the glass has turned to face you."* | `elapsed >= calmSeconds + noticingSeconds` (70s total) |
| `awake` | preview nearly clear (`blur: 1.5`, opacity `0.8`), vignette thin (`0.15`) — the ceiling; never fully clean | Poe at its most direct: *"it knows your face now."* → *"put the phone down. it will keep your face."* | player action only — `closeTheEye()`; `awake` does not self-terminate |
| any of the above | "close the eye" control, always visible, top-right | — | player taps it → `released` |

The escalation is **never faster than this clock** — `Atmosphere.beatSeconds`
(9s per line) and `EyeSession`'s `calmSeconds`/`noticingSeconds` (40s/30s
defaults) are the only things pacing dread. No jump cut, no sudden sting;
the camera preview itself never becomes fully clean at any phase (`awake`
still blurs at `radius: 1.5` and holds `0.8` opacity, not `1.0`) — restraint
is enforced in the render parameters, not just the copy.

**What ends the sitting:** either ending (`denied`, `released`) is a
complete, valid close. There is no "win" state and no forced continuation —
`awake` is a ceiling the player can leave at any time and is not required to
reach.

## 4. Camera use — what's actually happening on-device

`CameraController` (`CameraGate` conformance):

- **`requestAccess()`** — checks/asks `AVCaptureDevice.authorizationStatus(for: .video)`;
  never called before in-app consent (§1).
- **`start()`** — configures an `AVCaptureSession` (`.high` preset, front
  `builtInWideAngleCamera` input only) and starts it on a detached task;
  idempotent (`guard !isWatching`).
- **`stop()`** — stops the session on a detached task; safe to call whether
  or not it's running.
- **No recording, no file output, no `AVCaptureMovieFileOutput` or photo
  output is configured anywhere in `CameraController`.** The session exists
  solely to drive `AVCaptureVideoPreviewLayer` (`CameraPreview`) — an
  on-device, real-time render target, not a capture-to-storage pipeline.
- **No network code touches the camera session or its output** — this
  slice has no network layer at all (see Scope §Out).
- **The raw feed is never shown clean.** `EyeView` always composites the
  preview through `.saturation(0)`, a phase-dependent blur, a phase-dependent
  opacity, and a dark vignette overlay — by construction, there is no code
  path in this slice that renders the unmodified camera feed to the screen.

**Acceptance-critical claim this spec makes:** *"nothing is recorded, nothing
leaves your phone"* (the in-app copy, §1) is true because there is no output
target other than the preview layer and no network stack in the slice — this
should be re-verified against `CameraController` on every change to it, the
same way a security-sensitive invariant would be.

## 5. The voice layer

`Atmosphere.narration(for: phase, beat: Atmosphere.beat(forElapsed: eye.elapsed))`
is the only source of on-screen narration text; `EyeView`/`ConsentView`/`EndingView`
never hardcode a line. Mapping used in this slice:

- **Kafka** — `seekingConsent` (the epigraph beside the honest consent copy)
  and `denied` (the merciful ending).
- **Beckett** — `watching`'s calm lines, and `released` (the merciful close).
- **Poe** — `noticing` and `awake`'s escalation.
- **Bulgakov** *(PR #5, landing)* — an aside line inside `seekingConsent`,
  `watching`, and `noticing`, alongside whichever register owns that phase;
  does not appear in `denied`/`released` (both stay purely merciful, per
  `AtmosphereTests.testBulgakovRunsAlongsideEveryActWithoutOwningTheFirstLine`).
  This slice's UI needs no change to carry Bulgakov once merged — `EyeView`/
  `ConsentView` already just render whatever `Atmosphere.script(for:)`
  returns for the phase; the voice layer's whole point is that the app is a
  pure function of it.

Lines advance on `Atmosphere.beatSeconds` (9s) and wrap deterministically if
a phase runs long (`Atmosphere.narration`'s modulo wrap,
`AtmosphereTests.testBeatsWrapDeterministically`) — a player who lingers in
`watching` past every line simply hears the register breathe again, never a
blank line or a crash.

## 6. Safety-invariant checklist (`CLAUDE.md` §1)

Every item must hold before this slice ships or re-ships after a change:

- [ ] **Consent is explicit, explained, revocable, default-deny.** In-app
  rationale shown before the OS prompt (§1); `ConsentLedger` starts empty;
  `mayUse(.camera)` is false until `grant` is called.
- [ ] **The panic switch always works**, from any phase with a camera open,
  with the exact guarantees in §2 — no reachable state where "close the eye"
  fails to stop the camera.
- [ ] **No forbidden sensor is reachable.** `Sensor` has no case for photos,
  contacts, location, or health — this slice only ever names `.camera`, and
  the type system, not a runtime check, is what makes the rest unreachable.
- [ ] **No genuine harm — uncanny, not traumatizing.** The preview is never
  shown fully clean (§3's render parameters); no jump-scare stings; escalation
  stays on the slow beat (§3) at every phase, including `awake`.
- [ ] **Never actually deceives the player.** The in-app copy's claims
  ("nothing is recorded," "nothing leaves your phone") are true of the actual
  `CameraController` implementation (§4), not just the fiction; the fiction
  (an eye that "wakes up") stays legible as the game's premise, never implies
  a real external actor or a real data event.
- [ ] **No PII in the repo, logs, or telemetry.** This slice has no logging
  or telemetry code at all; if any is added later, camera frames and any
  face-derived data must never be part of it.

## 7. Acceptance criteria & test plan

### Already covered (`LULLKit`, pure, no camera, no simulator)

| behavior | test |
|---|---|
| Nothing watches before consent; asking is not watching | `EyeSessionTests.testBeginAsksForConsentFirst` |
| Denial is respected and terminal — time cannot revive it | `EyeSessionTests.testDenialIsRespectedAndTerminal` |
| Consent opens the eye calm; camera only wanted once consented | `EyeSessionTests.testConsentOpensTheEyeCalm` |
| Escalation follows the clock: calm → noticing → awake | `EyeSessionTests.testDreadEscalatesOnTheClock` |
| Release works from any phase, camera stops instantly | `EyeSessionTests.testReleaseClosesTheEyeFromAnyPhase` |
| A huge `dt` (backgrounding) cannot fast-forward the arc | `EyeSessionTests.testBackgroundingCannotFastForwardTheHorror` |
| Default is deny; grant is scoped; revoke is immediate; panic clears everything; every sensor has an honest rationale | `ConsentTests` (`testDefaultIsDeny`, `testGrantIsScopedToOneSensor`, `testRevokeStopsAccessImmediately`, `testPanicRevokeAllClearsEverything`, `testEverySensorHasAnHonestRationale`) |
| Each act speaks in its intended register; only `dormant` is silent; beats wrap; time deepens the line; the denial line is merciful | `AtmosphereTests` |

### Gaps — not currently covered, should be before this spec is called complete

- [ ] **No automated coverage of the app-layer wiring** (`GameModel`,
  `CameraController`, `ConsentView`, `EyeView`, `RootView`). In particular:
  the OS-permission-denied branch of `allowTheEye()` (consent granted
  in-app, then revoked because the OS said no) has a LULLKit-level
  equivalent (`consent(false)` reachable) but no test exercises the actual
  `GameModel.allowTheEye()` code path that walks the grant back. This is a
  fail-closed path and should get first-class coverage — either a unit test
  against a fake `CameraGate` that returns `false` from `requestAccess()`,
  or a documented manual QA step if a fake-camera test harness isn't worth
  building yet.
- [ ] **No test pins that the camera preview is never rendered clean.** §3's
  and §4's blur/opacity/vignette claims are currently just source code, not
  an assertion — worth a lightweight test (even a snapshot or a parameter
  bounds-check on `EyeView.previewOpacity`/blur radius) so "never shown
  clean" can regress loudly instead of silently.
- [ ] **No test that `stop()` is actually called before `.released` routes
  away from `EyeView`** — today this is true by code inspection (§2, step 4)
  but not pinned by an automated check.

### Manual QA (device required — Simulator's front camera is a no-op)

- [ ] Deny at the OS system prompt (not in-app) → lands on `.denied`, same
  ending copy as declining in-app.
- [ ] Grant, then background the app for several minutes, then foreground →
  phase has not skipped ahead of what real elapsed time (clamped per-tick)
  would produce.
- [ ] Tap "close the eye" mid-`awake`, confirm (visually, and via device
  camera-in-use indicator) the camera stops immediately.
- [ ] Full sitting, uninterrupted, `watching → noticing → awake`, confirm
  the preview is never legible as a clean video feed at any point.
