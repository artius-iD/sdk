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
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.54/ArtiusIDiOSSDK.xcframework.zip",
            checksum: "a0fe6d2a634cb142fa0c8f2549ff44e4072c7eb7c121e2ef88e1c92f4b831d21"
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
