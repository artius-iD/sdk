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
            url: "https://github.com/artius-iD/sdk/releases/download/v3.2.1/OpenSSL.xcframework.zip",
            checksum: "aa0f10a507d0574320dab373b88e640ff0a31778320fc2543e6f39690dcc62cb"
        ),
        .binaryTarget(
            name: "artiusid_sdk_ios",
            url: "https://github.com/artius-iD/sdk/releases/download/v3.2.1/artiusid_sdk_ios.xcframework.zip",
            checksum: "aedb9231d83336c996ea7912aa7f037c9b949749f3a41cfb2f9c7b6818acc293"
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
