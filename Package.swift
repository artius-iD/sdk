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
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.77/OpenSSL.xcframework.zip",
            checksum: "f9bfdcfae95274889f975a292fe70ecaa5204acb700d5882cf15ae256f4dd6d9"
        ),
        .binaryTarget(
            name: "artiusid_sdk_ios",
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.77/artiusid_sdk_ios.xcframework.zip",
            checksum: "72d02684b60246b6439b417954041ea5c7c9e162cb32439cf12fddc481fac864"
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
