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
            url: "https://github.com/artius-iD/sdk/releases/download/v3.2.0/OpenSSL.xcframework.zip",
            checksum: "91d1218b6a9264a95b7a473675d21344e4b5fbcd14bbd56b9a8346e7c4117d08"
        ),
        .binaryTarget(
            name: "artiusid_sdk_ios",
            url: "https://github.com/artius-iD/sdk/releases/download/v3.2.0/artiusid_sdk_ios.xcframework.zip",
            checksum: "d05109fc35b6985cd3ba98bc949105d741a62d2d8a7f45b8219b8bc21dab5787"
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
