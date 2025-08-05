// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ArtiusIDiOSSDK",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "ArtiusIDiOSSDK", targets: ["ArtiusIDSDKWrapper"]),
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "ArtiusIDiOSSDKBinary",
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.67/artiusid_sdk_ios.xcframework.zip",
            checksum: "4eb7c92b3fde1db0a9fdb7681638f7a1fbec8015ea6575999cc9aee5fc032317"
        ),
        .target(
            name: "ArtiusIDSDKWrapper",
            dependencies: [
                "ArtiusIDiOSSDKBinary"
            ],
            path: "Sources/ArtiusIDSDKWrapper"
        )
    ]
)
