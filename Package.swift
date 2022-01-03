// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Strong Karma Folder",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "MeditationViewFeature", targets: ["MeditationViewFeature"]),
        .library(name: "Models", targets: ["Models"]),
        .library(name: "NotificationHelper", targets: ["NotificationHelper"]),
        .library(name: "PickerFeature", targets: ["PickerFeature"])
    ],
    dependencies: [
        .package(url: "https://github.com/miiha/composable-user-notifications", from: "0.2.0"),
    ],
    targets: [
        .target(
            name: "MeditationViewFeature",
            dependencies: [
                "PickerFeature",
                "Models",
                .product(name: "ComposableUserNotifications", package: "composable-user-notifications")
            ]
        ),
        .target(
            name: "Models"),
        .target(
            name: "NotificationHelper"),
        .target(
            name: "PickerFeature"),
    ]
)
