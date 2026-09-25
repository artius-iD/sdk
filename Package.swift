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
            url: "https://github.com/artius-iD/sdk/releases/download/v3.1.4/OpenSSL.xcframework.zip",
            checksum: "e99c66298ab743cbb3fb2ce342330e3483467c1353354fefa315d8107d883f44"
        ),
        .binaryTarget(
            name: "artiusid_sdk_ios",
            url: "https://github.com/artius-iD/sdk/releases/download/v3.1.4/artiusid_sdk_ios.xcframework.zip",
            checksum: "8fb8ff835ff4e27350d1b876325b4c54d5d4b504844bce7c69da973ac88707a4"
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
