// swift-tools-version:5.8

import PackageDescription

let package = Package(
  name: "HTTPClient",
  platforms: [
    .macOS(.v10_15),
    .iOS(.v13)
  ],
  products: [
    // 🌐 An easy to use HTTPClient built on top of URLSession
    .library(
      name: "HTTPClient",
      targets: ["HTTPClient", "HTTPClientCore"]
    ),
    // 🌐🚜 An easy to use HTTPClient built for Combine on top of URLSession and Foundation Combine's conveniences
    .library(
      name: "CombineHTTPClient",
      targets: ["CombineHTTPClient", "HTTPClientCore"]
    ),
    // 🔎 A test support framework that can help you on testing or mocking the HTTPClient
    .library(
      name: "HTTPClientTestSupport",
      targets: ["HTTPClientTestSupport"]
    )
  ],
  dependencies: [
    // 🌳 A Logging API package for Swift
    .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "HTTPClientCore",
      dependencies: [],
      swiftSettings: [
        .enableExperimentalFeature("StrictConcurrency")
      ]
    ),
    .testTarget(
      name: "HTTPClientCoreTests",
      dependencies: [
        .target(name: "HTTPClientCore"),
        .target(name: "HTTPClientTestSupport"),
      ],
      swiftSettings: [
        .enableExperimentalFeature("StrictConcurrency")
      ]
    ),
    .target(
      name: "HTTPClient",
      dependencies: [
        .product(name: "Logging", package: "swift-log"),
        .target(name: "HTTPClientCore")
      ],
      swiftSettings: [
        .enableExperimentalFeature("StrictConcurrency")
      ]
    ),
    .target(
      name: "HTTPClientTestSupport",
      dependencies: [.target(name: "HTTPClient")],
      swiftSettings: [
        .enableExperimentalFeature("StrictConcurrency")
      ]
    ),
    .testTarget(
      name: "HTTPClientTests",
      dependencies: [
        .target(name: "HTTPClient"),
        .target(name: "HTTPClientTestSupport")
      ],
      swiftSettings: [
        .enableExperimentalFeature("StrictConcurrency")
      ]
    ),
    .target(
      name: "CombineHTTPClient",
      dependencies: [
        .product(name: "Logging", package: "swift-log"),
        .target(name: "HTTPClientCore")
      ],
      swiftSettings: [
        .enableExperimentalFeature("StrictConcurrency")
      ]
    ),
    .testTarget(
      name: "CombineHTTPClientTests",
      dependencies: [
        .target(name: "CombineHTTPClient"),
        .target(name: "HTTPClientTestSupport")
      ],
      swiftSettings: [
        .enableExperimentalFeature("StrictConcurrency")
      ]
    )
  ]
)
