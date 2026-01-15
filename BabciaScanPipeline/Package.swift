// swift-tools-version: 6.0
// Added 2026-01-14 22:55 GMT

import PackageDescription

let package = Package(
    name: "BabciaScanPipeline",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "BabciaScanPipeline",
            targets: ["BabciaScanPipeline"]
        )
    ],
    dependencies: [
        .package(path: "../DreamRoomEngine")
    ],
    targets: [
        .target(
            name: "BabciaScanPipeline",
            dependencies: [
                .product(name: "DreamRoomEngine", package: "DreamRoomEngine")
            ]
        )
    ]
)
