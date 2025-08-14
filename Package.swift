// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "artiusid_sdk_ios",
    platforms: [.iOS(.v13)],
.products: [
    .library(name: "artiusid_sdk_ios", targets: ["ArtiusIDSDKWrapper"]),
    .library(name: "ArtiusIDSDKWrapper", targets: ["ArtiusIDSDKWrapper"]),
],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "OpenSSL",
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.80/OpenSSL.xcframework.zip",
            checksum: "34b46e0ef422759c58edb1f5f17ddbd5311ed074372aabe6a24fe78cfdf46367"
        ),
        .binaryTarget(
            name: "artiusid_sdk_ios",
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.80/artiusid_sdk_ios.xcframework.zip",
            checksum: "4841c74e07f8d6345920a051977dcfbdff5252e0f63ff9a4c6727c5e4796d9d3"
        ),
        .target(
            name: "ArtiusIDSDKWrapper",
            dependencies: [
                "artiusid_sdk_ios",
                "OpenSSL"
            ],
            path: "Sources/ArtiusIDSDKWrapper"
        )
    ]
)
