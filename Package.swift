// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "AVMetaWriter",
  platforms: [.macOS(.v12)],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0")

  ],
  targets: [
    .executableTarget(
      name: "AVMetaWriter",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser")
      ],
    )
  ]
)
