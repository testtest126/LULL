# LULL — iOS app

The vertical slice: **`THE EYE`**. A SwiftUI + AVFoundation front-camera
experience, every step gated through `LULLKit`'s consent foundation.

## Build

The Xcode project is *generated* from `project.yml` (no `.xcodeproj` is committed
— it's derived, like everything else in this repo):

```sh
brew install xcodegen        # once
cd app && xcodegen           # generates LULL.xcodeproj
open LULL.xcodeproj          # then build + run on a real device
```

No XcodeGen? Create a new iOS App target in Xcode 15+, add the files in
`Sources/`, and add the local `LULLKit` package as a dependency — the sources
are plain SwiftUI, nothing exotic.

## What it does

1. **Asks in-app first.** The honest reason (`Sensor.camera.rationale`) is shown
   *before* the OS prompt. A "no" at either level is final — nothing watches.
2. **Opens the front camera**, degraded and never shown clean. No frame is
   recorded, and nothing leaves the device.
3. **Runs the clock**: `EyeSession` moves *calm → noticing → awake* on a timer.
4. **"Close the eye"** is always present — it revokes consent and stops the
   camera at once (the panic switch).

The decisions all live in `LULLKit` (`EyeSession`, `ConsentLedger`) and are
unit-tested; this layer is the thin skin over proven logic.

> Requires a real device — the front camera does nothing in the Simulator.
