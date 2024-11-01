// swift-tools-version:6.0

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
    targets: [
        .target(
            name: "MenuKit"
        ),
    ],
    swiftLanguageModes: [.v6]
)
