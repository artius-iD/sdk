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
            url: "https://github.com/artius-iD/sdk/releases/download/v3.0.11/OpenSSL.xcframework.zip",
            checksum: "7248c8e7f3987d61ad9e9c216022cbfff364dcd69733ec7e71afcda8a864cdad"
        ),
        .binaryTarget(
            name: "artiusid_sdk_ios",
            url: "https://github.com/artius-iD/sdk/releases/download/v3.0.11/artiusid_sdk_ios.xcframework.zip",
            checksum: "0edea7584c7c59130eccedca4038410a8f2adf903ef6df4367db1805c17a5435"
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
