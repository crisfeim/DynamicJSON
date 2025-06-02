// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QuickProto",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        .library(
            name: "QuickProto",
            targets: ["QuickProto"]
        )
    ],
    targets: [
        .target(name: "QuickProto"),
        .testTarget(
            name: "QuickProtoTests",
            dependencies: ["QuickProto"],
            resources: [.copy("Files")]
        )
    ]
)
