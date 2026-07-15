# ASSESSMENT — SwiftGodot as an engine layer for LULL

*Experiment, not a commitment (same spirit as `docs/ideation/`). Grounded in a
real spike under `DreadBeacon/` — see that folder and `README.md` for exactly
what compiled and what didn't get run. Facts below were checked against the
live `migueldeicaza/SwiftGodot` repo on 2026-07-15, not assumed.*

## Bottom line

**Stay native for the current roadmap, including the upcoming `THE MIRROR`
mechanic.** LULL's leverage is the phone's sensors plus the type-enforced
consent core (`ConsentLedger`, `CameraGate`, `EyeSession`) — SwiftUI/SpriteKit
already deliver that, with no second engine, no second editor, and no fresh
toolchain requirement. Revisit SwiftGodot only if LULL commits to real 3D
fidelity that SpriteKit/Canvas layering genuinely can't sell — and even then,
adopt it as a **hybrid** (Godot owns rendering/atmosphere; `LULLKit` stays the
sole, untouched authority for consent and sensor access), never as the whole
app shell (i.e. not `SwiftGodotKit`-drives-the-app).

## What I verified, live, against the repo (2026-07-15)

- `migueldeicaza/SwiftGodot`: MIT, actively maintained (pushed 2026-06-25),
  latest tag **v0.75.0** (published 2026-02-22) — matches the brief.
- Two consumption modes confirmed in the README: build a GDExtension Godot
  loads, or embed/drive Godot from Swift via the companion `SwiftGodotKit`.
- Quickstart tools **SwiftGodotKick**, **SwiftGodotCLI**, **SwiftGodotBinary**
  all exist, as does **GodotApplePlugins** and its companion template
  **SwiftGodotAppleTemplate**.
- **Toolchain requirement is understated in the README.** It says "requires
  Swift 5.9 or Xcode 15" — but the `Package.swift` actually tagged at
  `v0.75.0` declares `// swift-tools-version: 6.0`, and `main` HEAD (as of
  this spike) has moved to `6.3`. A contributor on Xcode 15/16 stable
  literally cannot resolve this package; this machine only builds it because
  it has Xcode-beta 27.0 / Swift 6.4 installed (`xcode-select` otherwise
  points at Command Line Tools only, which lack `XCTest` and can't run
  `LULLKit`'s own test suite either — an unrelated but real gap in this
  environment, noted for completeness).

## What I built (the spike)

`DreadBeacon/` is a standalone SwiftPM package (see its `Package.swift`) with
one `@Godot class DreadBeacon: Node3D` (`Sources/DreadBeacon/DreadBeacon.swift`)
that spawns an `OmniLight3D` and pulses/dims it on a slow 9-second beat —
mirroring `Atmosphere.beatSeconds`'s pacing in spirit, not by importing it.
Entry point is the `#initSwiftExtension` macro (`Sources/DreadBeacon/Entry.swift`),
per the README's documented pattern. `godot-project/` has a hand-written
`.gdextension`, `project.godot`, and `main.tscn`.

**`swift build` succeeds** (confirmed: `cd DreadBeacon && swift build`, and
`swift build -c release`). The built `libDreadBeacon.dylib` genuinely exports
`_swift_entry_point` and the `DreadBeacon` class symbols (checked with `nm`).

**Nothing was opened in a Godot editor or run on a device/simulator.** This
machine has no Godot 4.x install (checked: no `godot`/`godot4` binary, no
`.app`, `mdfind` finds nothing). The `.gdextension` and Godot project files
are written by hand from the README's documented format and are **unverified**
— I did not see a light pulse anywhere. Manual steps to actually run it are in
`README.md`. Do not read "it compiles" as "it renders."

## Two real SwiftPM blockers this spike hit (undocumented gotchas, worth knowing before anyone else tries this)

1. **Package-identity collision.** A spike rooted in a directory literally
   named `swiftgodot` — which is exactly what the task brief asked for
   (`experiments/swiftgodot/`) — fails with a cryptic
   `product 'SwiftGodot' ... not found in package 'SwiftGodot'` error, because
   SwiftPM derives the *root* package's identity from its directory name, and
   that collides case-insensitively with the dependency's own identity
   (derived from its URL). Fix: nest the actual SwiftPM package one directory
   deeper with a different name (`DreadBeacon/`), which is why this spike is
   laid out that way rather than with `Package.swift` at the top level.
2. **Unsafe build flags block version pins.** SwiftGodot's targets declare
   `.unsafeFlags(["-Xlinker", "-undefined", "-Xlinker", "dynamic_lookup"])`
   (needed for GDExtension's dynamic symbol resolution). SwiftPM forbids
   unsafe flags in any dependency resolved via SemVer (`.exact`, `.upToNextMajor`,
   `from:`) — this is a **known, still-open SwiftGodot issue
   (`#175`, filed 2023)**, and it still reproduces today against the current
   `v0.75.0` tag (I hit it directly: `.package(url:..., exact: "0.75.0")` fails
   with `the target 'SwiftGodot' ... contains unsafe build flags`).
   The practical consequence: **you cannot depend on a tagged SwiftGodot
   release through normal SwiftPM version pinning at all.** The workaround —
   confirmed against SwiftGodotKick's own project generator, which does this —
   is to pin a `revision:` (a commit SHA) instead of a version. That's what
   `DreadBeacon/Package.swift` does, pinned to the exact commit this spike was
   built against. This means LULL would always be floating on unreleased
   `main`, pinned by commit, never on a clean tagged release — a real tension
   with `CLAUDE.md` §2's "verify, don't assume" / green-from-commit-one
   instinct, since "stable version" isn't actually available as a concept
   here.

## SwiftGodotBinary is not the fast path it looks like

The brief suggested preferring the prebuilt `SwiftGodotBinary` xcframework
"for sane build times." Checked live: **`SwiftGodotBinary`'s `Package.swift`
is pinned to SwiftGodot `0.60.1` and hasn't been touched since April 2025** —
over a year behind the current `v0.75.0` (Feb 2026). It has no releases newer
than old pre-split version tags (`v0.21`, `0.60.1`, ...). Using it today means
building against an API surface roughly 15 releases stale. This spike used
the source dependency instead (see blocker #2 above for why that's also not
frictionless).

## Build cost, measured

- Clean build from a cold `swift build` (first fetch of ~742 planning steps,
  full source compile of `SwiftGodot`/`SwiftGodotRuntime`'s generated Godot-API
  bindings): several minutes.
- Rebuild from `rm -rf .build` with warm SwiftPM package caches: **73 seconds**
  (`swift build`, debug).
- Full `-c release` optimized build: **363 seconds** (~6 minutes), warm caches.
- Compare: `LULLKit`'s entire `swift build`/`swift test` — **well under a
  second**, every time, per its own README claim (16→20 tests, "green from
  commit one"). SwiftGodot is a different order of magnitude, every time
  someone does a clean checkout or bumps the pinned revision.

## Bundle size, measured

`libSwiftGodot.dylib` (the full generated Godot API surface, release build):
**34MB**, linked dynamically (`@rpath`) by the tiny 76KB `DreadBeacon.dylib`
(checked with `otool -L`). That 34MB — plus whatever Godot's own runtime
adds at export — has to ship inside the iOS app bundle. `LULLKit` + the
current SwiftUI app are, by contrast, native Swift/SwiftUI/AVFoundation code
with no comparable payload.

## What SwiftGodot would actually buy

- A real scene graph, lighting (`OmniLight3D` et al.), shaders, and an
  audio-bus mixer — plausibly a nicer authoring surface for
  `docs/ideation/mirror-and-still-here.md`'s bathroom scene (layered parallax,
  flicker, the vignette lighting) than hand-rolled SwiftUI `Canvas`/SpriteKit
  layers, if the team is willing to learn a second editor.
- Visual scene authoring (`.tscn` in the Godot editor) instead of code-only
  layout — could speed up atmosphere iteration once a scene gets complex.
- **The "no GC stutter" pitch in SwiftGodot's own README is largely moot for
  LULL.** That's an argument for Swift over *C#* inside Godot — it says
  nothing about Swift-in-Godot vs. LULL's actual alternative, which is
  SwiftUI/SpriteKit, also ARC, also GC-free today. Not a real differentiator
  here; flagging because the task brief listed it as a "buy."

## What SwiftGodot would actually cost

- **The consent invariant would cross a wider boundary.** `LULLKit` enforces
  "horror by permission" in the Swift type system today — `Sensor` has no
  case for a forbidden sensor, `ConsentLedger` gates everything, and
  `EyeSession`/`CameraGate` are pure, sensor-free, and instantly testable.
  Godot-in-the-loop doesn't have to break this — `LULLKit` can stay
  untouched and authoritative — but it does mean camera frames / mic buffers
  / motion data would need to cross Swift → GDExtension C ABI → Godot engine
  before becoming pixels/audio, and *that* boundary is exactly where
  "verify, don't assume" gets harder to test without a running Godot instance.
  This is maintainable discipline, not a free property, and it would need to
  be actively enforced (e.g. "Godot never touches `AVFoundation`/`CoreMotion`
  directly — only `LULLKit`-gated values flow in").
- **GodotApplePlugins does not hand you camera or microphone capture.**
  Checked its `Sources/` directly: it currently ships `GodotARKit`,
  `GodotAVFoundation` (which — checked the actual source — wraps only
  `AVAudioSession`, i.e. audio *session* category/route configuration, **not**
  camera capture or microphone recording), `GodotCoreMotion`,
  `GodotAuthenticationServices`, `GodotGameCenter`, `GodotStoreKit`,
  `GodotFoundation`. `GodotCoreMotion` is a direct win for `Sensor.motion`.
  But `THE EYE` (front camera) and `THE ROOM` (microphone) — LULL's two most
  central mechanics — have **no ready-made bridge**. Someone would need to
  hand-write a custom GDExtension bridging `AVCaptureSession` frames into a
  Godot `Texture2D`/`ImageTexture` and mic buffers into a Godot audio stream —
  real native engineering, not something adopted for free by pulling in
  SwiftGodot + GodotApplePlugins, contrary to how the task brief framed it.
- **Real, measured build/bundle cost** (see above): minutes instead of
  sub-second builds; tens of megabytes instead of a thin native binary.
  Directly in tension with a lean, small-team, fast-iteration project.
- **iOS export and App Review surface get heavier and less familiar.**
  Shipping a GDExtension means bundling the Godot runtime itself, and
  GodotApplePlugins' own README explicitly warns each linked capability
  (ARKit, etc.) invites an App Review question — "why are you calling ARKit
  if your app has no AR capabilities" — even for capabilities you don't use.
  For a camera-driven horror app that already has to survive an adversarial
  App Review read (`CLAUDE.md` §3), adding an engine most reviewers don't
  associate with a "sleep aid app" is added, not reduced, review risk. iOS
  GDExtension export conventionally wants static linking rather than the
  runtime-dlopen'd `.dylib` this spike produced for macOS — not verified here,
  and exactly the kind of detail that would need its own spike before
  trusting it.
- **A second toolchain, a second editor, a second project format** — for a
  project whose own process principle (`CLAUDE.md` §4) is "solo / small,"
  adding Godot's editor + `.tscn`/`project.godot` + GDExtension export
  alongside Xcode + XcodeGen + `run.sh` is real surface-area growth, not a
  wash.

## Recommendation, concretely

1. **`THE EYE` (shipped) and `THE MIRROR` (next, per the ideation doc): stay
   native.** The ideation doc's own plan — `CIFilter` distortion, a frame-delay
   ring buffer, a layered SwiftUI `Canvas`/SpriteKit scene — is buildable with
   the stack LULL already has, keeps the consent boundary at its current
   tightness, and doesn't add a 34MB dependency or a six-minute release build
   to a project that currently builds and tests in under a second.
2. **Don't adopt `SwiftGodotKit`** (Godot-drives-the-app-shell) at all for
   LULL. That would relocate the *entire* presentation layer — including,
   eventually, sensor-adjacent UI — into an engine with no built-in
   camera/mic bridge and a much wider boundary from the consent core. For a
   horror-by-permission game, that boundary is the whole ethical spine; don't
   widen it for engine convenience.
3. **Revisit only if/when LULL commits to real 3D** (a modeled space with
   proper lighting/shaders genuinely beyond what SpriteKit/Canvas can sell) —
   and even then, scope it as a strict hybrid: Godot renders; `LULLKit`
   remains the sole, unmodified gatekeeper for every sensor; camera/mic/motion
   data reaches Godot only as already-consented, already-gated values (frames,
   not raw `AVCaptureSession` access) that LULLKit hands across the boundary.
   Before that decision: get an actual Godot 4.6 editor on a dev machine and
   confirm this spike's node truly registers and renders (not done here);
   prototype the `AVCaptureSession`-frame-into-`Texture2D` bridge specifically,
   since nothing in the ecosystem I found does this today; and accept that the
   whole team moves to whatever very-recent Xcode/Swift toolchain SwiftGodot's
   *actual* (not README-stated) tools-version floor requires.
