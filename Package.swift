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
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.170/OpenSSL.xcframework.zip",
            checksum: "34c6ad7fd1e784a839fa161d43721ead51c508f162d61b106c54c0c82aa1995a"
        ),
        .binaryTarget(
            name: "artiusid_sdk_ios",
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.170/artiusid_sdk_ios.xcframework.zip",
            checksum: "b3fb1341695faa7aaa5aba73194c5b4b6dc79e87e48202854487469012476a17"
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
