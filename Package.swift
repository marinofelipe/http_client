// swift-tools-version:5.2

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
            targets: ["HTTPClient"]
        ),
        // 🌐🚜 An easy to use HTTPClient built for Combine on top of URLSession and Foundation Combine's conveniences
        .library(
            name: "CombineHTTPClient",
            targets: ["CombineHTTPClient"]
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
            dependencies: []
        ),
        .testTarget(
            name: "HTTPClientCoreTests",
            dependencies: [
                .target(name: "HTTPClientCore"),
                .target(name: "HTTPClientTestSupport"),
            ]
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
            dependencies: [
                .target(name: "HTTPClient"),
                .target(name: "HTTPClientTestSupport")
            ]
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
            dependencies: [
                .target(name: "CombineHTTPClient"),
                .target(name: "HTTPClientTestSupport")
            ]
        )
    ]
)
