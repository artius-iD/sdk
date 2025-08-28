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
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.162/OpenSSL.xcframework.zip",
            checksum: "73e8cc7a778f5da37e1a043446a6d38d8bed03392881268741ff323e8d9468b4"
        ),
        .binaryTarget(
            name: "artiusid_sdk_ios",
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.162/artiusid_sdk_ios.xcframework.zip",
            checksum: "130edfd32b9aa733fbe5a926d7aa1d63ee16b336993be80cc6ca7954006e92f2"
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
