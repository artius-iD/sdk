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
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.121/artiusid_sdk_ios.xcframework.zip",
            checksum: "c3172abfa418aa3829b1532863e9e47084d347e2c74d8e60c0087bfadb87c5a0"
         ),
        .binaryTarget(
            name: "artiusid_sdk_ios",
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.121/artiusid_sdk_ios.xcframework.zip",
            checksum: "630a05992c8defcac0147c09660e13f022a2d7d3bfa01b3d2ac9c8289e1d1c60"
        ),
        .target(
            name: "ArtiusIDSDKWrapper",
            dependencies: [
                "artiusid_sdk_ios",
                "OpenSSL"
            ],
            path: "Sources"
        )
    ]
)
