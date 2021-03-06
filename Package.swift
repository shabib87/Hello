// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Hello",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13)
    ],
    products: [
        .library(name: "Hello", targets: ["Hello"]),
        .executable(name: "hello", targets: ["Hello"])
    ],
    dependencies: [
//         .package(url: "https://github.com/apple/swift-tools-support-core.git",
//                        from: "0.0.1"),
//         .package(url: "https://github.com/apple/swift-argument-parser",
//                        from: "0.0.1"),
    ],
    targets: [
        .target(
            name: "Hello",
            dependencies: []),
//            dependencies: ["ArgumentParser", "SwiftToolsSupport"]),
        .testTarget(
            name: "HelloTests",
            dependencies: ["Hello"]),
    ]
)
