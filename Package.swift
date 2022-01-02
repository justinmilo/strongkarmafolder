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
    ],
    targets: [
        .target(
            name: "MeditationViewFeature"),
        .target(
            name: "Models"),
        .target(
            name: "NotificationHelper"),
        .target(
            name: "PickerFeature"),
    ]
)
