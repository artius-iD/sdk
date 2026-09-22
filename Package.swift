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
            url: "https://github.com/artius-iD/sdk/releases/download/v3.1.2/OpenSSL.xcframework.zip",
            checksum: "1b65f02ff241e2b2f60aebd6ae639e935fe6c77c88e5d910b864955fda893449"
        ),
        .binaryTarget(
            name: "artiusid_sdk_ios",
            url: "https://github.com/artius-iD/sdk/releases/download/v3.1.2/artiusid_sdk_ios.xcframework.zip",
            checksum: "9cf3f7ca4ec94a07564ab1359aa6308cbc5d17a02c9d80a1e1eeeff41340e869"
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
