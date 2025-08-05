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
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.58/ArtiusIDiOSSDK.xcframework.zip",
            checksum: "222deeec879b16e85877403bb5e5da68102214d3528d20567a7dda8f7cd66501"
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
