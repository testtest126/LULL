# Atmosphere (experiment)

**Branch:** [`experiment/spritekit-atmosphere`](https://github.com/testtest126/LULL/tree/experiment/spritekit-atmosphere)
**PR:** [#1 — "Experiment: SpriteKit atmosphere layer"](https://github.com/testtest126/LULL/pull/1) (draft)

This is explicitly framed in the PR description as **"a prototype, not a
decision"** — evaluating whether SpriteKit earns its place as a dependency of
LULL's real fear mechanics, before committing to it.

## What's in it

- **`app/Sources/AtmosphereScene.swift`** — an `SKScene` that is pure
  decoration: slow drifting fog (`SKEmitterNode`), faint upward dust motes, a
  static vignette (a generated radial-gradient texture, no shader), a slow
  breathing red glow ("pulse"), and a rare, brief flicker. It owns no state,
  reads no sensor, and knows nothing about consent or `EyeSession` — per its
  own doc comment, "delete this file and the app behaves exactly as it did
  before." The palette is copied from `Theme.swift` by eye (not imported), so
  the file stays independently liftable/deletable.
- **`app/Sources/AtmosphereBackground.swift`** — a `SpriteView` bridge that
  puts `AtmosphereScene` into SwiftUI as a background layer, with no
  reference to `GameModel`, consent, or the camera.
- **`app/Sources/LULLApp.swift`** — a one-line swap in `RootView`'s `ZStack`:
  `Theme.ink.ignoresSafeArea()` → `AtmosphereBackground()` as the base layer,
  sitting *behind* the existing consent/eye UI.
- **`app/project.yml`** — adds `INFOPLIST_KEY_UILaunchScreen_Generation: YES`.
  Called out in the PR as unrelated to SpriteKit itself — a pre-existing gap
  (the app was rendering letterboxed in the Simulator for lack of a launch
  screen) that had to be fixed to see the atmosphere full-screen.

## What it explicitly is *not*

Per the PR description:

- No touches to `LULLKit`, `ConsentLedger`, `EyeSession`, or the camera
  pipeline. `AtmosphereScene` holds no state and reaches no sensor.
- No new dependencies — SpriteKit is first-party (part of the OS SDK).
- Nothing removed — `ConsentView`, `EyeView`, and `GameModel` are untouched;
  this is strictly an additive background layer.

## Verification claimed in the PR

- `swift test` in `LULLKit`: 16/16 green, unchanged (consistent with what
  [Building & Running](Building-and-Running) documents for `main`).
- `xcodegen generate` + `xcodebuild` for `iphonesimulator`: builds clean.
- Run in the iPhone 17 Pro simulator: the atmosphere layer renders
  full-screen behind the consent title, with a visibly breathing glow and
  vignette.

## The honest take (from the PR author, in the PR itself)

The PR's own "Honest read" section is worth preserving verbatim in spirit,
because it's a well-reasoned argument *against* over-adopting the framework
it just introduced:

> Restrained particle/glow work like this is well within reach of
> `Canvas`/`TimelineView` + Core Animation, and SpriteKit's advantage would
> show up more once there's actual interactivity — things reacting to
> touch/face/time in real time, physics, sprite-sheet animation — rather than
> ambient decoration. Ambient-only, lean SwiftUI to keep the surface area
> small; but SpriteKit is a lot less awkward for this than expected, so if
> `THE EYE`'s escalation ever wants particle reactions tied to the camera
> signal, it's a reasonable investment.

In short: for purely decorative atmosphere (fog, dust, vignette, ambient
glow), plain SwiftUI/Core Animation likely does the job with less framework
surface area to maintain. SpriteKit's case gets stronger the moment the dread
needs to *react* — to the camera signal, to touch, to time, in a way that
benefits from a real scene graph and physics/particle system rather than
declarative animation.

## Status

Draft PR, not merged. Reading it as a decision record: the prototype proves
SpriteKit *can* sit cleanly behind the existing UI without touching game
logic, but whether it's worth adopting is explicitly left open pending
whether future mechanics need reactive behavior, not just ambience.
