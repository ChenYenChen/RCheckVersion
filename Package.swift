// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RCheckVersion",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(
            name: "RCheckVersion",
            targets: ["RCheckVersion"]),
    ],
    targets: [
        .target(
            name: "RCheckVersion",
            dependencies: []),
        .testTarget(
            name: "RCheckVersionTests",
            dependencies: ["RCheckVersion"]),
    ]
)
