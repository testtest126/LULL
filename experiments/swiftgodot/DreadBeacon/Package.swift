// swift-tools-version: 6.0
import PackageDescription

// EXPERIMENT — see ../ASSESSMENT.md. Not part of the shippable LULLKit/app
// graph; nothing here is depended on by, or depends on, LULLKit.
let package = Package(
    name: "DreadBeacon",
    platforms: [.macOS(.v14), .iOS(.v17)],
    products: [
        .library(name: "DreadBeacon", type: .dynamic, targets: ["DreadBeacon"])
    ],
    dependencies: [
        // NOT pinned to the v0.75.0 tag, and NOT the stale SwiftGodotBinary
        // xcframework — see ASSESSMENT.md. SwiftGodot's targets carry
        // `.unsafeFlags` (`-Xlinker -undefined -Xlinker dynamic_lookup`),
        // and SwiftPM refuses unsafe flags in any *version-pinned* (tag/exact)
        // dependency (migueldeicaza/SwiftGodot#175, open since 2023; still
        // reproduces against v0.75.0 as of this spike). Pinning to a `revision:`
        // (a commit SHA, not a tag) is SwiftPM's own workaround — the
        // unsafe-flags check only fires for SemVer-resolved dependencies —
        // and matches what the community's own SwiftGodotKick generator does
        // (pins `revision:`, never a version). Trade-off: this floats past
        // the tagged v0.75.0 release onto unreleased `main`, pinned to the
        // exact commit this spike was built and verified against.
        .package(url: "https://github.com/migueldeicaza/SwiftGodot", revision: "5a9ffab8f7c11d7872f50d6c02fdb278b6e532b2")
    ],
    targets: [
        .target(
            name: "DreadBeacon",
            dependencies: [
                .product(name: "SwiftGodot", package: "SwiftGodot")
            ]
        )
    ]
)
