// swift-tools-version: 5.9

import PackageDescription

let android = Context.environment["TARGET_OS_ANDROID"] ?? "0" != "0"

let package = Package(
  name: "swift-navigation",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
    .tvOS(.v13),
    .watchOS(.v6),
  ],
  products: [
    .library(
      name: "SwiftNavigation",
      targets: ["SwiftNavigation"]
    ),
    .library(
      name: "SwiftUINavigation",
      targets: ["SwiftUINavigation"]
    ),
    .library(
      name: "UIKitNavigation",
      targets: ["UIKitNavigation"]
    ),
    .library(
      name: "AppKitNavigation",
      targets: ["AppKitNavigation"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-collections", from: "1.0.0"),
    .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-case-paths", from: "1.5.6"),
    .package(url: "https://github.com/pointfreeco/swift-concurrency-extras", from: "1.2.0"),
    .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "1.3.2"),
    .package(url: "https://github.com/flote-works/swift-perception", branch: "flote/service-app"),
    .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "1.4.1"),
  ]
    + (android ? [
      .package(url: "https://source.skip.tools/skip-bridge.git", "0.16.4"..<"2.0.0"),
      .package(url: "https://source.skip.tools/skip-android-bridge.git", "0.6.1"..<"2.0.0"),
      .package(url: "https://source.skip.tools/swift-jni.git", "0.3.1"..<"2.0.0"),
    ] : []),
  targets: [
    .target(
      name: "SwiftNavigation",
      dependencies: [
        .product(name: "CasePaths", package: "swift-case-paths"),
        .product(name: "CustomDump", package: "swift-custom-dump"),
        .product(name: "ConcurrencyExtras", package: "swift-concurrency-extras"),
        .product(name: "IssueReporting", package: "xctest-dynamic-overlay"),
        .product(name: "OrderedCollections", package: "swift-collections"),
        .product(name: "Perception", package: "swift-perception"),
        .product(name: "PerceptionCore", package: "swift-perception"),
      ]
    ),
    .testTarget(
      name: "SwiftNavigationTests",
      dependencies: [
        "SwiftNavigation",
        .product(name: "IssueReportingTestSupport", package: "xctest-dynamic-overlay"),
      ]
    ),
    .target(
      name: "SwiftUINavigation",
      dependencies: [
        "UIKitNavigation",
        .product(name: "CasePaths", package: "swift-case-paths"),
        .product(name: "IssueReporting", package: "xctest-dynamic-overlay"),
      ]
        + (android ? [
          .product(name: "SkipBridge", package: "skip-bridge"),
          .product(name: "SkipAndroidBridge", package: "skip-android-bridge"),
          .product(name: "SwiftJNI", package: "swift-jni"),
        ] : [])
    ),
    .testTarget(
      name: "SwiftUINavigationTests",
      dependencies: [
        "SwiftUINavigation",
        .product(name: "IssueReportingTestSupport", package: "xctest-dynamic-overlay"),
      ]
    ),
    .target(
      name: "UIKitNavigation",
      dependencies: [
        "SwiftNavigation",
        "UIKitNavigationShim",
        .product(name: "ConcurrencyExtras", package: "swift-concurrency-extras"),
        .product(name: "IssueReporting", package: "xctest-dynamic-overlay"),
      ]
    ),
    .target(
      name: "UIKitNavigationShim"
    ),
    .target(
      name: "AppKitNavigation",
      dependencies: [
        "SwiftNavigation"
      ]
    ),
    .testTarget(
      name: "UIKitNavigationTests",
      dependencies: [
        "UIKitNavigation",
        .product(name: "IssueReportingTestSupport", package: "xctest-dynamic-overlay"),
      ]
    ),
  ]
)

for target in package.targets {
  target.swiftSettings = target.swiftSettings ?? []
  target.swiftSettings!.append(contentsOf: [
    .enableExperimentalFeature("StrictConcurrency")
  ])
  // target.swiftSettings?.append(
  //   .unsafeFlags([
  //     "-enable-library-evolution",
  //   ])
  // )
}
