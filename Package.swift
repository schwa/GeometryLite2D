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
        .library(name: "GeometryCollections", targets: ["GeometryCollections"]),
        .library(name: "Interaction", targets: ["Interaction"]),
        .library(name: "Visualization", targets: ["Visualization"]),
        .library(name: "Thicken", targets: ["Thicken"]),
        .library(name: "Voronoi", targets: ["Voronoi"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.0"),
        .package(url: "https://github.com/apple/swift-numerics.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "Geometry",
            dependencies: [
                "Interaction",
                "Visualization",
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "Numerics", package: "swift-numerics")
            ]
        ),
        .target(
            name: "GeometryCollections",
            dependencies: [
                "Geometry",
                .product(name: "Collections", package: "swift-collections")
            ]
        ),
        .target(name: "Visualization", dependencies: []),
        .target(name: "Interaction", dependencies: ["Visualization"]),
        .target(
            name: "Thicken",
            dependencies: ["Geometry", "GeometryCollections"]
        ),
        .target(
            name: "Voronoi",
            dependencies: ["Geometry"]
        ),
        .testTarget(name: "GeometryTests", dependencies: ["Geometry", "GeometryCollections"]),
        .testTarget(name: "ThickenTests", dependencies: ["Thicken", "Geometry"]),
        .testTarget(name: "VoronoiTests", dependencies: ["Voronoi", "Geometry"])
    ]
)
