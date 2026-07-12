// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "LULLKit",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "LULLKit", targets: ["LULLKit"]),
    ],
    targets: [
        .target(name: "LULLKit"),
        .testTarget(name: "LULLKitTests", dependencies: ["LULLKit"]),
    ]
)
