// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GDPerformanceView-Swift",
    platforms: [.iOS(.v8)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "GDPerformanceView-Swift",
            targets: ["GDPerformanceView-Swift"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "GDPerformanceView-Swift",
            dependencies: [],
            path: "./GDPerformanceView-Swift/GDPerformanceMonitoring"),
        .testTarget(
            name: "GDPerformanceView-SwiftTests",
            dependencies: ["GDPerformanceView-Swift"]),
    ]
)
