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
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.28/ArtiusIDSDK.xcframework.zip",
            checksum: "0d60917220fea3ab955b015ceb653ff2966327aa2a01aa2d36a77b65513a9335"
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
