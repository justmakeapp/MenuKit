// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "MenuKit",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        .library(
            name: "MenuKit",
            targets: ["MenuKit"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MenuKit",
            dependencies: []
        ),
    ]
)
