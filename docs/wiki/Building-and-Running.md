# Building & Running

## Requirements

- Xcode 15+ (iOS 17 deployment target)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)
- A **real iPhone**, not the Simulator, if you want to see `THE EYE` actually
  work — the front camera does nothing in the Simulator.

## Generate and open the app project

The `.xcodeproj` is not committed — it's generated from `app/project.yml`,
the same way the rest of the repo treats derived artifacts:

```sh
brew install xcodegen        # once
cd app
xcodegen                     # generates LULL.xcodeproj
open LULL.xcodeproj          # then build + run on a real device
```

No XcodeGen available? Per `app/README.md`: create a new iOS App target in
Xcode 15+, add the files under `app/Sources/`, and add the local `LULLKit`
package as a dependency. The sources are plain SwiftUI — nothing exotic.

`app/project.yml` sets the important App-Review-facing bits directly:

- `PRODUCT_BUNDLE_IDENTIFIER`: `io.github.testtest126.lull`
- `INFOPLIST_KEY_NSCameraUsageDescription`: the honest camera rationale
  string shown by the OS
- Deployment target: iOS 17.0

## What running it does

From `app/README.md`, in order:

1. **Asks in-app first.** `Sensor.camera.rationale` is shown before the OS
   prompt. A "no" at either level is final — nothing watches.
2. **Opens the front camera**, degraded and never shown clean. No frame is
   recorded; nothing leaves the device.
3. **Runs the clock**: `EyeSession` moves `calm → noticing → awake` on a
   timer.
4. **"Close the eye"** is always present — it revokes consent and stops the
   camera immediately (the panic switch).

## Testing `LULLKit`

`LULLKit` is a standalone Swift package and builds/tests independent of the
iOS app or a simulator:

```sh
cd LULLKit
swift test
```

As of this writing that's **16 tests** across three files — `ConsentTests`,
`EyeSessionTests`, `AtmosphereTests` — covering the consent invariants (see
[The Safety Invariant](The-Safety-Invariant)), the `EyeSession` phase machine
(including the anti-fast-forward clamp), and the `Atmosphere` narration
layer. Per the README and `CLAUDE.md`, this suite is meant to stay green from
commit one and every commit after — it's the project's "perft," the
executable proof that consent and the dread clock behave as designed.

> `swift test` requires a full Swift toolchain with XCTest available (ships
> with Xcode's command-line tools). A bare Swift toolchain without Xcode may
> not have `XCTest` on its module search path.
