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
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.164/OpenSSL.xcframework.zip",
            checksum: "6b4e85cd28169d071da3d2d055a44af74c6135407fa09281d31955cfea584900"
        ),
        .binaryTarget(
            name: "artiusid_sdk_ios",
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.164/artiusid_sdk_ios.xcframework.zip",
            checksum: "55481a1a0b25fa74277ab662b1dc9b4b2c1c4bc626a99dfde34815b248bfd243"
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
                "Environments.swift",
                "LogLevel.swift",
                "VerificationResult.swift"
            ]
        )
    ]
)
