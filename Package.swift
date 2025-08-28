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
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.158/OpenSSL.xcframework.zip",
            checksum: "43506d66f1b5bed71ba1cba5e637539f962551eea3d743c58693193112254232"
        ),
        .binaryTarget(
            name: "artiusid_sdk_ios",
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.158/artiusid_sdk_ios.xcframework.zip",
            checksum: "102e5c3e7958edc8dc3979daeccf55961ea9529589b9782ea9dfc048e6e295b6"
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
