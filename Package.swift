// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PokemonKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13)
    ],
    products: [
        .library(
            name: "PokemonKit",
            targets: ["PokemonKit"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.15.3")
    ],
    targets: [
        .target(
            name: "PokemonKit",
            dependencies: [
                .product(name: "SQLite", package: "SQLite.swift")
            ],
            path: "PokemonKit/Sources",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PokemonKitTests",
            dependencies: ["PokemonKit"],
            path: "PokemonKit/Tests"
        )
    ]
)
