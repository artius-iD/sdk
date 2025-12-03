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
            url: "https://github.com/artius-iD/sdk/releases/download/v2.0.45/OpenSSL.xcframework.zip",
            checksum: "424b1a0a658ace55214b952fe3d952f7abba19e41b23246e289065c994629910"
        ),
        .binaryTarget(
            name: "artiusid_sdk_ios",
            url: "https://github.com/artius-iD/sdk/releases/download/v2.0.45/artiusid_sdk_ios.xcframework.zip",
            checksum: "e38781ee66baba567f28b4633a8379a006b087deadf9d646ebb1c114841cc77b"
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
