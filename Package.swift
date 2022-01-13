// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Strong Karma Folder",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "AppFeature", targets: ["AppFeature"]),
        .library(name: "MeditationViewFeature", targets: ["MeditationViewFeature"]),
        .library(name: "Models", targets: ["Models"]),
        .library(name: "PrepViewFeature", targets: ["PrepViewFeature"]),
        .library(name: "PickerFeature", targets: ["PickerFeature"]),
        .library(name: "EditEntryViewFeature", targets: ["EditEntryViewFeature"]),
        .library(name: "ListViewFeature", targets: ["ListViewFeature"]),
        .library(name: "ParsingHelpers", targets: ["ParsingHelpers"]),
        .library(name: "TimerBottomFeature", targets: ["TimerBottomFeature"])
    ],
    dependencies: [
        .package(url: "https://github.com/miiha/composable-user-notifications", from: "0.2.0"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.14.0"),
        .package(url: "https://github.com/pointfreeco/swift-parsing", from: "0.3.1")
    ],
    targets: [
        .target(
          name: "AppFeature",
          dependencies: [
            "ListViewFeature",
            "MeditationViewFeature",
            "Models",
            "ParsingHelpers",
            .product(name: "Parsing", package: "swift-parsing"),
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            .product(name: "ComposableUserNotifications", package: "composable-user-notifications")
          ]
        ),
        .target(
            name: "ListViewFeature",
            dependencies: [
                "Models",
                "MeditationViewFeature",
                "EditEntryViewFeature",
                "TimerBottomFeature",
                "ParsingHelpers",
                .product(name: "Parsing", package: "swift-parsing"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "MeditationViewFeature",
            dependencies: [
                "PickerFeature",
                "Models",
                "PrepViewFeature",
                .product(name: "ComposableUserNotifications", package: "composable-user-notifications"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "Models"
        ),
        .target(
          name: "ParsingHelpers",
          dependencies: [
            .product(name: "Parsing", package: "swift-parsing")
          ]
        ),
        .target(
            name: "PrepViewFeature"
        ),
        .target(
            name: "PickerFeature"
        ),
        .target(
            name: "EditEntryViewFeature",
            dependencies: [
                "Models",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "TimerBottomFeature",
            dependencies: [
                "MeditationViewFeature",
                "Models",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        )
    ]
)
