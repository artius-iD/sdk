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
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.90/OpenSSL.xcframework.zip",
            checksum: "fc41c44807a20f28e48988280c9b10428566b6f66ec329a559d5edc6abb02086"
        ),
        .binaryTarget(
            name: "artiusid_sdk_ios",
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.90/artiusid_sdk_ios.xcframework.zip",
            checksum: "0539bb9f8dc4e3360b7af0b4c5deedd8027315a7f8a580def0ed28c9cc3b11b3"
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
