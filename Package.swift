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
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.133/OpenSSL.xcframework.zip",
            checksum: "5eaa385b60afe0658288fbd43f67e3833293171e36a27abe75c9c452ac72cb8f"
        ),
        .binaryTarget(
            name: "artiusid_sdk_ios",
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.133/artiusid_sdk_ios.xcframework.zip",
            checksum: "be0437c1aac7ec0a5f4344b323d796eb1153b28e235aaef7518a14dc1828e82e"
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
