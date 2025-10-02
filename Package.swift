// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "artiusid_sdk_ios",
    platforms: [.iOS(.v13)],
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
            url: "https://github.com/artius-iD/sdk/releases/download/v1.0.231/OpenSSL.xcframework.zip",
            checksum: "18d1863c6e35b80f20915b3e55df5f3650c7625ff933e4f2deb10cdc63c98ba6"
        ),
        .binaryTarget(
            name: "artiusid_sdk_ios",
            url: "https://github.com/artius-iD/sdk/releases/download/v1.0.231/artiusid_sdk_ios.xcframework.zip",
            checksum: "cb4ff970e8c22eead0ab248807286af7776ef2472ecc067f1ced3216430c95b8"
        ),
        .target(
            name: "ArtiusIDSDKWrapper",
            dependencies: [
                "artiusid_sdk_ios",
                "OpenSSL"
            ],
            path: "Sources",
            sources: [
                "ArtiusIDSDKWrapper.swift",
                "VerificationResult.swift"
            ]
        )
    ]
)
