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
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.160/OpenSSL.xcframework.zip",
            checksum: "1086a9c8528e97004e5217da392715f6a5e0db549855f712b5bda0a85f1cb4fe"
        ),
        .binaryTarget(
            name: "artiusid_sdk_ios",
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.160/artiusid_sdk_ios.xcframework.zip",
            checksum: "dc417d5758bdebff0687ecbdf209a05f786be3a0ecae3c64d3c935391b599786"
        ),
        .target(
            name: "ArtiusIDSDKWrapper",
            dependencies: [
                "artiusid_sdk_ios",
                "OpenSSL"
            ],
            path: "Sources",
            sources: [
                "VerificationResult.swift"
            ]
        )
    ]
)
