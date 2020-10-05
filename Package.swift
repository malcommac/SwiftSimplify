// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SwiftSimplify",
    platforms: [
        .iOS(.v8),
        .watchOS(.v2),
        .tvOS(.v9)
    ],
    products: [
        .library(name: "SwiftSimplify", targets: ["SwiftSimplify"])
    ],
    targets: [
        .target(name: "SwiftSimplify"),
        .testTarget(name: "SwiftSimplifyTests", dependencies: ["SwiftSimplify"], resources: [.process("SimplifyTestPoints.json")])
    ]
)
