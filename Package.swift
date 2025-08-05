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
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.53/ArtiusIDiOSSDK.xcframework.zip",
            checksum: "31c3605d787d330c848fcb52f832802f1763e89add1a1584547b57db6710bc89"
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
