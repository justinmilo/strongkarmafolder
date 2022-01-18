// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Strong Karma Folder",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "AppFeature", targets: ["AppFeature"]),
        .library(name: "Models", targets: ["Models"]),
        .library(name: "PrepViewFeature", targets: ["PrepViewFeature"]),
        .library(name: "PickerFeature", targets: ["PickerFeature"]),
        .library(name: "EditEntryViewFeature", targets: ["EditEntryViewFeature"]),
        .library(name: "ListViewFeature", targets: ["ListViewFeature"]),
        .library(name: "ParsingHelpers", targets: ["ParsingHelpers"]),
        .library(name: "TCAHelpers", targets: ["TCAHelpers"]),
        .library(name: "TimedSessionViewFeature", targets: ["TimedSessionViewFeature"]),
        .library(name: "TimerBottomFeature", targets: ["TimerBottomFeature"]),
        .library(name: "SwiftUIHelpers", targets: ["SwiftUIHelpers"])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-case-paths", from: "0.7.0"),
        .package(url: "https://github.com/miiha/composable-user-notifications", from: "0.2.0"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.14.0"),
        .package(url: "https://github.com/pointfreeco/swift-parsing", from: "0.3.1")
    ],
    targets: [
        .target(
          name: "AppFeature",
          dependencies: [
            "EditEntryViewFeature",
            "ListViewFeature",
            "TimedSessionViewFeature",
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
                "TCAHelpers",
                "TimedSessionViewFeature",
                "EditEntryViewFeature",
                "SwiftUIHelpers",
                "TimerBottomFeature",
                "ParsingHelpers",
                .product(name: "Parsing", package: "swift-parsing"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "TimedSessionViewFeature",
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
          name: "SwiftUIHelpers",
          dependencies: [
            .product(name: "CasePaths", package: "swift-case-paths")
          ]
        ),
        .target(
          name: "TCAHelpers",
          dependencies: [
            .product(name: "CasePaths", package: "swift-case-paths"),
            .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
          ]
        ),
        .target(
            name: "TimerBottomFeature",
            dependencies: [
                "TimedSessionViewFeature",
                "Models",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        )
    ]
)
