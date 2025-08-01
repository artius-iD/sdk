// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ArtiusIDSDK",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "ArtiusIDSDK", targets: ["ArtiusIDSDKWrapper"]),
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "ArtiusIDSDK",
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.36/ArtiusIDSDK.xcframework.zip",
            checksum: "30cfe820042fba71d07c527cb2d8ab729a22dc62a09b8b3d99442f4b4c654b06"
        ),
        .target(
            name: "ArtiusIDSDKWrapper",
            dependencies: [
                "ArtiusIDSDK"
            ],
            path: "Sources/ArtiusIDSDKWrapper"
        )
    ]
)
