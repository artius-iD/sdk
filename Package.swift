// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "artiusid_sdk_ios",
    platforms: [.iOS("18.2")],
    products: [
        .library(
            name: "ArtiusIDSDK",
            targets: ["ArtiusIDSDKWrapper"]
        )
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "OpenSSL",
            url: "https://github.com/artius-iD/sdk/releases/download/v3.2.3/OpenSSL.xcframework.zip",
            checksum: "9eba539d58fb3ab795b6f28e3d87433c3c0f88d708dcf3f9c8ee9a5b3640673f"
        ),
        .binaryTarget(
            name: "artiusid_sdk_ios",
            url: "https://github.com/artius-iD/sdk/releases/download/v3.2.3/artiusid_sdk_ios.xcframework.zip",
            checksum: "6810cc2e7293e3ca846f97f7a545fcf1a7420794672373b41e55f63018f9fcb2"
        ),
        .target(
            name: "ArtiusIDSDKWrapper",
            dependencies: [
                "artiusid_sdk_ios",
                "OpenSSL"
            ],
            path: "Sources",
            sources: [
                "ArtiusIDSDKWrapper.swift"
            ]
        )
    ]
)
