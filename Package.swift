// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "GeometryLite2D",
    platforms: [
        .macOS(.v15),
        .iOS(.v18)
    ],
    products: [
        .library(name: "Geometry", targets: ["Geometry"]),
        .library(name: "Visualization", targets: ["Visualization"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.0"),
        .package(url: "https://github.com/apple/swift-numerics.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "Geometry",
            dependencies: [
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "Numerics", package: "swift-numerics")
            ]
        ),
        .target(
            name: "Visualization",
            dependencies: [
                "Geometry"
            ]
        ),
        .testTarget(
            name: "GeometryTests",
            dependencies: ["Geometry"]
        )
    ]
)
