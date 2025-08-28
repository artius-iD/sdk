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
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.159/OpenSSL.xcframework.zip",
            checksum: "3a7a643cb8d560b2abe8f55ca4c1431d81b4614811a35f8b04e088ca4f0736be"
        ),
        .binaryTarget(
            name: "artiusid_sdk_ios",
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.159/artiusid_sdk_ios.xcframework.zip",
            checksum: "df8132e9ba2a65eb22c3a0c173a75081756b2e51aa6d19ee783d1672642270f5"
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
