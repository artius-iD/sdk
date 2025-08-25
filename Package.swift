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
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.145/OpenSSL.xcframework.zip",
            checksum: "a34a1c8a8e83de9001d1c2ddddc0d92a3ffbe3a45c53c2003dbe9433a1db00af"
        ),
        .binaryTarget(
            name: "artiusid_sdk_ios",
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.145/artiusid_sdk_ios.xcframework.zip",
            checksum: "e18ab972a543c1abe1f7033b0a4ededfe9b68ccdcb8465c8dc22739ef37ff070"
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
