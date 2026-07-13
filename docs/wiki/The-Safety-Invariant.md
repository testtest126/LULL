# The Safety Invariant

LULL's README and `CLAUDE.md` both say the "one rule" — horror by permission,
not violation — is "enforced in code." That's true, but it's true of **one
half** of the guarantee and not the other. This page states precisely which
half is which, because overclaiming here is exactly the kind of thing App
Review (and any careful reader) will catch.

## Two separate claims

1. **"LULL cannot even name a forbidden sensor."** — Photos, contacts,
   location, and health data.
2. **"The camera never runs without consent."** — The one sensor LULL *does*
   use, gated correctly every time.

These are different kinds of guarantee, verified differently.

## Claim 1 — genuinely compiler-enforced

In [`LULLKit/Sources/LULLKit/Consent.swift`](https://github.com/testtest126/LULL/blob/main/LULLKit/Sources/LULLKit/Consent.swift):

```swift
public enum Sensor: String, CaseIterable, Sendable, Codable {
    case camera
    case microphone
    case notifications
    case haptics
    case motion
}
```

`Sensor` is a closed Swift `enum`. There is no `case` for photos, contacts,
location, or health data. `ConsentLedger.grant(_:)`, `.mayUse(_:)`, and every
other consent API take a `Sensor` as their parameter type — so **no line of
Swift anywhere in this codebase can express "ask for contacts" or "read
location."** It isn't refused at runtime; it can't be written, full stop. To
add such a sensor, someone would have to edit `Consent.swift` itself, in a
diff any reviewer would immediately see for what it is.

This is a real type-system guarantee, not a policy or a runtime check. It's
the strongest kind of promise a codebase can make.

## Claim 2 — currently a disciplined call site, not a compiler guarantee

The camera is *allowed* to exist (`Sensor.camera` is a valid case), so the
type system can't forbid using it — it can only help make sure it's used
correctly. Today, "correctly" is enforced by a hand-written sequence, not by
a type that makes the wrong order impossible.

Trace the actual call path in
[`app/Sources/GameModel.swift`](https://github.com/testtest126/LULL/blob/main/app/Sources/GameModel.swift):

```swift
func allowTheEye() async {
    consent.grant(.camera)
    guard await camera.requestAccess() else {
        consent.revoke(.camera)
        eye.consent(false)
        return
    }
    eye.consent(true)
    await camera.start()
    startClock()
}
```

This is the *only* place in the app that calls `camera.start()`, and the
sequencing — grant consent, then ask the OS, then start — is correct as
written and matches the "in-app first, OS prompt second" rule from
`CLAUDE.md`. But look at
[`CameraController`](https://github.com/testtest126/LULL/blob/main/app/Sources/CameraController.swift)
and [`EyeSession`](https://github.com/testtest126/LULL/blob/main/LULLKit/Sources/LULLKit/Eye.swift)
themselves:

- `CameraController.start()` has **no internal check** against
  `ConsentLedger` or `EyeSession.wantsCamera`. It will start the capture
  session if you call it — from anywhere, at any time. It trusts its caller.
- `EyeSession.wantsCamera` is a *derived, read-only property* the app is
  expected to consult ("the app asks this and nothing else," per the doc
  comment) — but nothing in the types forces `GameModel` to actually check it
  before calling `camera.start()`. `GameModel` happens to only call `start()`
  right after `eye.consent(true)`, but that's the current code being
  well-behaved, not a constraint the compiler would catch if a future call
  site skipped it.
- Nothing stops a hypothetical new call site (a new view, a debug button, a
  future feature) from constructing its own `CameraController` and calling
  `.start()` directly, bypassing `ConsentLedger` and `EyeSession` entirely.
  The compiler would accept that code.

So: the *shape* of the guarantee that exists today is "one reviewed function,
`GameModel.allowTheEye()`, does the right thing, and it's the only place that
touches the camera." That's a real, verifiable property of the *current*
codebase — but it's a convention upheld by there being one call site and a
small team, not an invariant the type system defends against a second call
site being added carelessly.

`closeTheEye()` (the panic switch) has the same shape: it's correct today —
it cancels the clock, calls `eye.release()`, `consent.revokeAll()`, and
`camera.stop()` — but nothing types-check that *every* path capable of
starting the camera is paired with a path that can stop it.

## What would close the gap

Not implemented — noted here as the honest "what a stronger version would
look like," not as a roadmap commitment:

- Have `CameraController.start()` (or a wrapper) take a `ConsentLedger` or an
  `EyeSession` snapshot as a required argument, so the compiler refuses to
  compile a call site that doesn't supply proof of consent.
- Make `CameraGate` conformances only obtainable through a factory that
  requires a granted `ConsentLedger`, so `CameraController` can't be
  constructed and started independently of the consent flow.

## What's tested today

The consent *logic* itself — independent of whether every call site respects
it — is unit-tested in
[`ConsentTests.swift`](https://github.com/testtest126/LULL/blob/main/LULLKit/Tests/LULLKitTests/ConsentTests.swift)
and
[`EyeSessionTests.swift`](https://github.com/testtest126/LULL/blob/main/LULLKit/Tests/LULLKitTests/EyeSessionTests.swift):
default-deny, per-sensor scoping, immediate revoke, the panic switch clearing
everything, denial being respected and terminal from any phase, and the
camera clock being unable to fast-forward past a backgrounded app. These are
real, green, and pinned. What they don't and can't test is "every future call
site in the app will remember to check consent first" — that's the part that
currently relies on the app being small enough that one person can review
every call to `camera.start()` by eye.

## Bottom line

- **Forbidden sensors:** genuinely impossible to name in code. Compiler-level.
- **Consent gates the camera:** correctly wired today, verified by reading
  the single call site — but held up by code review and a small surface
  area, not by the type system. Worth re-checking any time a new call site
  touching `CameraController` is added.
