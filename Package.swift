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
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.29/ArtiusIDSDK.xcframework.zip",
            checksum: "d2db75188f21b48c21ca000a736814a614752b778f571b489c57f9e7aeb71914"
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
