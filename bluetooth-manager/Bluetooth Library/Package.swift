// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Bluetooth Library",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "Bluetooth Library",
            targets: ["Bluetooth Library"]),
    ],
    targets: [
        .target(name: "Bluetooth Library")
    ]
)
