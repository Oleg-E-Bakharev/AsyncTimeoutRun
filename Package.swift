// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AsyncTimeoutRun",
    products: [
        .library(
            name: "AsyncTimeoutRun",
            targets: ["AsyncTimeoutRun"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AsyncTimeoutRun",
            dependencies: []),
        .testTarget(
            name: "AsyncTimeoutRunTests",
            dependencies: ["AsyncTimeoutRun"]),
    ]
)
