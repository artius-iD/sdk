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
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.191/OpenSSL.xcframework.zip",
            checksum: "c61ba51f8247787e1f9411cb080c0201a116f41920aabc221d26925a1b97f89d"
        ),
        .binaryTarget(
            name: "artiusid_sdk_ios",
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.191/artiusid_sdk_ios.xcframework.zip",
            checksum: "80d0c164d32b14bae800c0dc0cbcf91bc8818a73c7eb1f2ae2e67927b1988361"
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
