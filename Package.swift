// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BabciaTobiasz",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "BabciaTobiasz",
            targets: ["BabciaTobiasz"]),
    ],
    dependencies: [
        .package(path: "DreamRoomEngine"),
        .package(path: "BabciaScanPipeline") // Added 2026-01-14 22:55 GMT
    ],
    targets: [
        .target(
            name: "BabciaTobiasz",
            dependencies: [
                .product(name: "DreamRoomEngine", package: "DreamRoomEngine"),
                .product(name: "BabciaScanPipeline", package: "BabciaScanPipeline") // Added 2026-01-14 22:55 GMT
            ],
            path: "BabciaTobiasz",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "BabciaTobiaszTests",
            dependencies: ["BabciaTobiasz"],
            path: "Tests/BabciaTobiaszTests"
        )
    ]
)
