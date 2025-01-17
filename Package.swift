// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "ZaberMotionLib",
    platforms: [.macOS(.v10_13),],
    products: [
        .library(
            name: "ZaberMotionLib",
            targets: ["ZaberMotion"]
        )
    ],
    targets: [
        // .binaryTarget(
        //     name: "ZaberMotionCore",
        //     url: "https://286092275994-us-west-2-colby--downloads.s3.us-east-1.amazonaws.com/downloads/ZML/Swift/ZaberMotionCore.xcframework.zip",
        //     checksum: "3b7e4bdcb2f741eb428b44800398d1961e0ad9c6849d9d32024cb9a5d64bfaf8"
        // ),
        .binaryTarget(
            name: "ZaberMotionCore",
            path: "ZaberMotionCore.xcframework.zip"
        ),
        .target(
            name: "ZaberMotion",
            dependencies: ["ZaberMotionCore"],
            path: "Sources/ZaberMotion"
        )
    ]
)

