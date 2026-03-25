// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "Networking",
  platforms: [.iOS(.v17)],
  products: [
    .library(
      name: "Networking",
      targets: ["Networking"]),
  ],
  targets: [
    .target(
      name: "Networking",
      swiftSettings: .defaultSettings),
    .testTarget(
      name: "NetworkingTests",
      dependencies: ["Networking"],
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
