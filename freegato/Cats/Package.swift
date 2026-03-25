// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "Cats",
  platforms: [.iOS(.v17)],
  products: [
    .library(name: "CatModels", targets: ["CatModels"]),
    .library(name: "CatServices", targets: ["CatServices"]),
    .library(name: "CatViews", targets: ["CatViews"]),
    .library(name: "Cats", targets: ["CatModels", "CatServices", "CatViews"]),
  ],
  dependencies: [
    .package(name: "Networking", path: "../Networking"),
    .package(url: "https://github.com/avdn-dev/VISOR.git", from: "8.0.0"),
  ],
  targets: [
    .target(
      name: "CatModels",
      swiftSettings: .defaultSettings),
    .target(
      name: "CatServices",
      dependencies: [
        "CatModels",
        .product(name: "Networking", package: "Networking"),
        .product(name: "VISOR", package: "VISOR"),
      ],
      resources: [.process("Resources")],
      swiftSettings: .defaultSettings),
    .target(
      name: "CatViews",
      dependencies: [
        "CatModels",
        "CatServices",
      ],
      swiftSettings: .defaultSettings),
    .testTarget(
      name: "CatsTests",
      dependencies: [
        "CatModels",
        "CatServices",
        "CatViews",
      ],
      swiftSettings: .defaultSettings),
  ])

extension [SwiftSetting] {
  static var defaultSettings: [SwiftSetting] {
    [
      .defaultIsolation(MainActor.self),
      .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
      .enableUpcomingFeature("InferIsolatedConformances"),
    ]
  }
}
