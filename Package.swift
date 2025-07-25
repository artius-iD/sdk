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
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.34/ArtiusIDSDK.xcframework.zip",
            checksum: "c188b713ae8114d2a01da6020bd25149afa808a02445de4cd37bd800ea7cd60f"
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
