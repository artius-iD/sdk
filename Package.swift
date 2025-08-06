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
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.68/artiusid_sdk_ios.xcframework.zip",
            checksum: "68f058098bee39f0b7948383f7ea839c01c5d559515c5d70c46a53e555eb182e"
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
