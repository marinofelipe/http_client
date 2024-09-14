# 🌐🚜 (Combine)HTTPClient

[![Swift 6.0](https://img.shields.io/badge/swift-6.0-ED523F.svg?style=flat)](https://swift.org/download/)
[![Swift Package Manager](https://rawgit.com/jlyonsmith/artwork/master/SwiftPackageManager/swiftpackagemanager-compatible.svg)](https://swift.org/package-manager/)
[![@_marinofelipe](https://img.shields.io/badge/contact-@_marinofelipe-5AA9E7.svg?style=flat)](https://twitter.com/_marinofelipe)

Simple HTTPClient(s) built on top of URLSession.

## Motivation

There are a lot of great open sourced and community-driven third-party networking libraries, such as [Moya](https://github.com/Moya/Moya) and [Alamofire](https://github.com/Alamofire/Alamofire). They are quite powerfull, can speed up development, and help you on different and more complex ways of networking.

For `some use cases though` I like the idea of something simpler, without the need to rely on yet another third party dependency. It's also a lot of fun to learn more about networking 😝.

This project is an `example on how to wrap URLSession, and provide an easy to use but still robust and well-tested API`. 
*Same concept* can be applied over *any other SDKs*, even when using a *third-party library*, since it's always a *good practice* to do not expose such logic to the outside world, making it easier to maintain and swap implementation in the future.

## Content
It comes with these array of libraries: **[HTTPClient, CombineHTTPClient, CombineHTTPClientTestSupport]**

Examples on how to use can them can taken seen in the unit tests 😉.
Both clients depends on HTTPClientCore, which contains shared helpers and common types.

## Installation

### Swift Package Manager

If you want to try it out in a project that uses [SPM](https://swift.org/package-manager/), just add it as a `dependency` in your `Package.swift`:

``` swift
dependencies: [
  .package(url: "https://github.com/marinofelipe/http_client.git", from: "0.0.1")
]
```

## License

All modules are released under the MIT license. See [LICENSE](LICENSE) for details.
