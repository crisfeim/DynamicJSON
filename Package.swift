// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AsyncView",
    platforms: [.iOS(.v14), .macOS(.v11)],
    products: [
        .library(
            name: "AsyncView",
            targets: ["AsyncView"]
        )
    ],
    targets: [
        .target(name: "AsyncView"),
        .testTarget(
            name: "AsyncViewTests",
            dependencies: ["AsyncView"],
            resources: [.copy("Files")]
        )
    ]
)
