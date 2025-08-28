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
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.163/OpenSSL.xcframework.zip",
            checksum: "79a6eb54a7e7ce8fd889829afcb34625f10543a565b8502a293b7faabae34103"
        ),
        .binaryTarget(
            name: "artiusid_sdk_ios",
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.163/artiusid_sdk_ios.xcframework.zip",
            checksum: "2a2866374a02c8e64365d8b2d03d926080f1a9471e3d72c4dea85f8bbf48f1a2"
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
                "Environment.swift",
                "LogLevel.swift",
                "VerificationResult.swift"
            ]
        )
    ]
)
