// swift-tools-version: 6.2

import CompilerPluginSupport
import PackageDescription

let mainActorIsolation: [SwiftSetting] = [
    .defaultIsolation(MainActor.self),
    .enableUpcomingFeature("InferIsolatedConformances"),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault")
]

let package = Package(
    name: "Modules",
    defaultLocalization: "en",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "API", targets: ["API"]),
        .library(name: "ComposableArchitectureSupport", targets: ["ComposableArchitectureSupport"]),
        .library(name: "Core", targets: ["Core"]),
        .library(name: "DesignSystem", targets: ["DesignSystem"]),
        .library(name: "Localisations", targets: ["Localisations"]),
        .library(name: "ProductDetails", targets: ["ProductDetails"]),
        .library(name: "ProductsList", targets: ["ProductsList"]),
        .library(name: "StyleGuide", targets: ["StyleGuide"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "1.26.2",
            traits: ["ComposableArchitecture2Deprecations"]
        ),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.17.2"),
        .package(url: "https://github.com/swiftlang/swift-syntax", "509.0.0"..<"605.0.0")
    ],
    targets: [
        // MARK: - Network

        .target(
            name: "API",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies")
            ]
        ),
        .testTarget(name: "APITests", dependencies: ["API"]),

        // MARK: - Foundations

        .target(name: "Core"),
        .testTarget(name: "CoreTests", dependencies: ["Core"]),

        .target(
            name: "StyleGuide",
            resources: [.process("Catalog.xcassets")],
            swiftSettings: mainActorIsolation
        ),

        .target(name: "Localisations", resources: [.process("Localizable.xcstrings")]),

        .target(
            name: "DesignSystem",
            dependencies: ["Localisations", "StyleGuide"],
            swiftSettings: mainActorIsolation
        ),

        .target(
            name: "ComposableArchitectureSupport",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            swiftSettings: mainActorIsolation
        ),

        // MARK: - Features

        .target(
            name: "ProductDetails",
            dependencies: ["API", "ComposableArchitectureSupport", "Core", "DesignSystem"],
            swiftSettings: mainActorIsolation
        ),

        .target(
            name: "ProductsList",
            dependencies: ["API", "ComposableArchitectureSupport", "Core", "DesignSystem"],
            swiftSettings: mainActorIsolation
        ),
        .testTarget(
            name: "ProductsListTests",
            dependencies: ["ProductsList"],
            swiftSettings: mainActorIsolation
        )
    ],
    swiftLanguageModes: [.v6]
)
