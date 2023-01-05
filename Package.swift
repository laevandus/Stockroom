// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Stockroom",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "Stockroom",
            targets: ["Stockroom"]
        ),
    ],
    targets: [
        .target(
            name: "Stockroom",
            dependencies: []
        ),
        .testTarget(
            name: "StockroomTests",
            dependencies: ["Stockroom"]
        ),
    ]
)
