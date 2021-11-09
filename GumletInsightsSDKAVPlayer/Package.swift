// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "GumletInsightsSDKAVPlayer",
  platforms: [
     .iOS(.v13)
  ],
  products: [
    .library(
      name: "GumletInsightsSDKAVPlayer",
      targets: ["GumletInsightsSDKAVPlayer"]),
  ],
  targets: [
    .binaryTarget(
      name: "GumletInsightsSDKAVPlayer",
      path: "./Sources/GumletInsightsSDKAVPlayer.xcframework"
    )
  ]
)


