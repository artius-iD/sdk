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
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.37/ArtiusIDSDK.xcframework.zip",
            checksum: "b04d9259bcbfca8d1eaa096ab7587cdbdb5ef053a4fd4586037c04502fb98117"
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
