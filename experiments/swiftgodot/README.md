# EXPERIMENT — SwiftGodot spike

Evaluates [SwiftGodot](https://github.com/migueldeicaza/SwiftGodot) (Swift
bindings for Godot 4.6 via GDExtension) as a possible engine layer for LULL.
**Isolated on purpose:** nothing here is depended on by, or depends on,
`LULLKit` or `app/` — the shippable game is untouched. See
[`ASSESSMENT.md`](ASSESSMENT.md) for the actual recommendation.

## What's here

- **`DreadBeacon/`** — a tiny SwiftGodot GDExtension: one `@Godot` `Node3D`
  subclass (`DreadBeacon`) that pulses an `OmniLight3D` on a slow 9-second
  "dread beat" and dims over ~2 minutes, echoing the pacing in
  `LULLKit/Sources/LULLKit/Atmosphere.swift` (reimplemented locally, not
  shared code — the point is to prove the toolchain, not build a feature).
  It's a separate Swift package rooted at `DreadBeacon/` — **not** at this
  directory — because a package rooted in a directory literally named
  `swiftgodot` collides in identity with the `SwiftGodot` dependency itself;
  see "Gotchas" in `ASSESSMENT.md`.
- **`godot-project/`** — a hand-written, **unverified** minimal Godot project
  (`project.godot`, `main.tscn`, `DreadBeacon.gdextension`) that *would* load
  the built extension. Nothing in this folder has been opened in a Godot
  editor — see Honesty below.

## What actually ran here

- `cd DreadBeacon && swift build` — **compiles**, on this machine
  (Xcode-beta 27.0 / Swift 6.4, DEVELOPER_DIR pointed at Xcode-beta since only
  Command Line Tools are the active `xcode-select` toolchain). Confirmed by
  running it: see `ASSESSMENT.md` for the exact command and the two real
  SwiftPM blockers it took to get there.
- **No Godot editor or runtime is installed on this machine.** The
  `.gdextension` file and Godot project were written by hand, following the
  SwiftGodot README's documented format, but never loaded, never launched,
  and the `DreadBeacon` light was never seen to actually pulse in an editor
  or on a device. Do not read "it compiles" as "it renders."

## To actually run it (manual steps, not verified on this machine)

1. Install the Godot 4.6 editor (this machine has none).
2. `cd experiments/swiftgodot/DreadBeacon && swift build -c release`
3. Copy the built dylib into the project: `cp .build/release/libDreadBeacon.dylib ../godot-project/bin/`
4. Open `experiments/swiftgodot/godot-project/project.godot` in Godot 4.6.
5. Run the project (F5). `main.tscn`'s `DreadBeacon` node should register as
   a custom class via the `.gdextension` and its `_ready()`/`_process()`
   should run.

If step 4 fails to see `DreadBeacon` as a known node type, the extension
likely isn't loading — check the Godot editor's output panel for a
GDExtension load error (mismatched `compatibility_minimum`, missing symbol,
wrong dylib path) before assuming the Swift side is wrong.
