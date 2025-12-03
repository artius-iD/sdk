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
            url: "https://github.com/artius-iD/sdk/releases/download/v2.0.39/OpenSSL.xcframework.zip",
            checksum: "5efdbf736e6a1c94a413839a9048445df35aec92ecf87070aca3cd032f33d277"
        ),
        .binaryTarget(
            name: "artiusid_sdk_ios",
            url: "https://github.com/artius-iD/sdk/releases/download/v2.0.39/artiusid_sdk_ios.xcframework.zip",
            checksum: "56aac884095ff9be17be8cd91db8ac59165b3dabc936c30724324ebf8244f982"
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
