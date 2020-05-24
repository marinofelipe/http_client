// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "HTTPClient",
    products: [
        .library(
            name: "HTTPClient",
            targets: ["HTTPClient"]
        ),
        .library(
            name: "CombineHTTPClient",
            targets: ["CombineHTTPClient"]
        )
    ],
    dependencies: [
        // 🌳 A Logging API package for Swift
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "HTTPClientCore",
            dependencies: []
        ),
        .testTarget(
            name: "HTTPClientCoreTests",
            dependencies: [.target(name: "HTTPClientCore")]
        ),
        .target(
            name: "HTTPClient",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .target(name: "HTTPClientCore")
            ]
        ),
        .target(
            name: "HTTPClientTestSupport",
            dependencies: [.target(name: "HTTPClient")]
        ),
        .testTarget(
            name: "HTTPClientTests",
            dependencies: [.target(name: "HTTPClient")]
        ),
        .target(
            name: "CombineHTTPClient",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .target(name: "HTTPClientCore")
            ]
        ),
        .testTarget(
            name: "CombineHTTPClientTests",
            dependencies: [.target(name: "CombineHTTPClient")]
        )
    ]
)
