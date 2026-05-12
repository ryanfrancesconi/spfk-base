// swift-tools-version: 6.2
// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi

import PackageDescription

let package = Package(
    name: "spfk-base",
    defaultLocalization: "en",
    platforms: [.macOS(.v13), .iOS(.v16),],
    products: [
        .library(
            name: "SPFKBase",
            targets: ["SPFKBase", "SPFKBaseC",]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/ryanfrancesconi/spfk-testing", from: "1.0.1"),
        .package(url: "https://github.com/orchetect/swift-extensions", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-numerics", from: "1.1.1"),
        .package(url: "https://github.com/apple/swift-collections", from: "1.3.0"),
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.1.1"),
    ],
    targets: [
        .target(
            name: "SPFKBase",
            dependencies: [
                .targetItem(name: "SPFKBaseC", condition: nil),
                .product(name: "SwiftExtensions", package: "swift-extensions"),
                .product(name: "Numerics", package: "swift-numerics"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
            ]
        ),
        .target(
            name: "SPFKBaseC",
            dependencies: [],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("include_private")
            ],
            cxxSettings: [
                .headerSearchPath("include_private")
            ]
        ),
        .testTarget(
            name: "SPFKBaseTests",
            dependencies: [
                .targetItem(name: "SPFKBase", condition: nil),
                .targetItem(name: "SPFKBaseC", condition: nil),
                .product(name: "SPFKTesting", package: "spfk-testing"),
            ]
        ),
    ],
    cxxLanguageStandard: .cxx20
)
