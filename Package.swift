// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription


let package = Package(
  name: "GumletInsightsAVPlayer",
  platforms: [
     .iOS(.v13)
  ],
  products: [
    .library(
      name: "GumletInsightsAVPlayer",
      targets: ["GumletInsightsAVPlayer"]),
  ],
  targets: [
    .binaryTarget(
      name: "GumletInsightsAVPlayer",
      path: "./Sources/GumletInsightsAVPlayer.xcframework"
    )
  ]
)
