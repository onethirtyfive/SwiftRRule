// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftRRule",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SwiftRRule",
            targets: ["SwiftRRule"]),
    ],
    dependencies: [
        .package(url: "https://github.com/malcommac/SwiftDate", .upToNextMajor(from: "6.3.1")),
        .package(url: "https://github.com/Quick/Quick", .upToNextMajor(from: "3.0.0")),
        .package(url: "https://github.com/Quick/Nimble", .upToNextMajor(from: "9.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SwiftRRule",
            dependencies: [
                "SwiftDate"
            ],
            path: "Source"),
        .testTarget(
            name: "SwiftRRuleTests",
            dependencies: [
                "SwiftRRule",
                "Quick",
                "Nimble"
            ],
            path: "Tests"
        )
    ]
)
