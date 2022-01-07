// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Strong Karma Folder",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "MeditationViewFeature", targets: ["MeditationViewFeature"]),
        .library(name: "Models", targets: ["Models"]),
        .library(name: "PrepViewFeature", targets: ["PrepViewFeature"]),
        .library(name: "PickerFeature", targets: ["PickerFeature"]),
        .library(name: "EditEntryViewFeature", targets: ["EditEntryViewFeature"]),
        .library(name: "TimerBottomFeature", targets: ["TimerBottomFeature"]),
        .library(name: "ListViewFeature", targets: ["ListViewFeature"])
    ],
    dependencies: [
        .package(url: "https://github.com/miiha/composable-user-notifications", from: "0.2.0"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.14.0")
    ],
    targets: [
        .target(
            name: "ListViewFeature",
            dependencies: [
                "Models",
                "MeditationViewFeature",
                "EditEntryViewFeature",
                "TimerBottomFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "MeditationViewFeature",
            dependencies: [
                "PickerFeature",
                "Models",
                .product(name: "ComposableUserNotifications", package: "composable-user-notifications"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "Models"
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
