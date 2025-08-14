// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "artiusid_sdk_ios",
    platforms: [.iOS(.v13)],
.products: [
    .library(name: "artiusid_sdk_ios", targets: ["ArtiusIDSDKWrapper"]),
    .library(name: "ArtiusIDSDKWrapper", targets: ["ArtiusIDSDKWrapper"]),
],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "OpenSSL",
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.84/OpenSSL.xcframework.zip",
            checksum: "74a1c69ec67c249c851ebe68136e5acf54aaf3415f9c64fdf05f7438b056b5d0"
        ),
        .binaryTarget(
            name: "artiusid_sdk_ios",
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.84/artiusid_sdk_ios.xcframework.zip",
            checksum: "bef4768a29781706c356b2fd1596d41f092743cba764ed92f67b4f9b461ba1ac"
        ),
        .target(
            name: "ArtiusIDSDKWrapper",
            dependencies: [
                "artiusid_sdk_ios",
                "OpenSSL"
            ],
            path: "Sources/ArtiusIDSDKWrapper"
        )
    ]
)
