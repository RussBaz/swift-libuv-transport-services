// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

#if os(Windows)
    let libuvTarget: Target = .systemLibrary(
        name: "Clibuv",
        providers: [
            .brew(["libuv"]),
            .apt(["libuv1-dev"]),
        ]
    )
#else
    let libuvTarget: Target = .systemLibrary(
        name: "Clibuv",
        pkgConfig: "libuv",
        providers: [
            .brew(["libuv"]),
            .apt(["libuv1-dev"]),
        ]
    )
#endif

let package = Package(
    name: "swift-libuv-transport-services",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "UVTransportServices",
            targets: ["UVTransportServices"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.72.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        libuvTarget,
        .target(
            name: "UVTransportServices",
            dependencies: [
                .target(name: "Clibuv"),
                .product(name: "NIOCore", package: "swift-nio"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "UVTransportServicesTests",
            dependencies: ["UVTransportServices"],
            swiftSettings: swiftSettings
        ),
    ]
)

let swiftSettings: [SwiftSetting] = [
    // Flags to enable Swift 6 compatibility
    .enableUpcomingFeature("BareSlashRegexLiterals"),
    .enableUpcomingFeature("ConciseMagicFile"),
    .enableUpcomingFeature("ForwardTrailingClosures"),
    .enableUpcomingFeature("ImportObjcForwardDeclarations"),
    .enableUpcomingFeature("DisableOutwardActorInference"),
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("DeprecateApplicationMain"),
    .enableUpcomingFeature("GlobalConcurrency"),
    .enableUpcomingFeature("IsolatedDefaultValues"),
    .enableExperimentalFeature("StrictConcurrency"),
    // Flags to warn about the type checking getting too slow
    .unsafeFlags(
        [
            "-Xfrontend",
            "-warn-long-function-bodies=100",
            "-Xfrontend",
            "-warn-long-expression-type-checking=100",
        ]
    ),
]
