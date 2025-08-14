// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GeometryLite2D",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "GeometryLite2D",
            targets: ["GeometryLite2D"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "GeometryLite2D"
        ),
        .testTarget(
            name: "GeometryLite2DTests",
            dependencies: ["GeometryLite2D"]
        ),
    ]
)
