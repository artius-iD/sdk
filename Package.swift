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
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.131/OpenSSL.xcframework.zip",
            checksum: "96ae374e78ec14d0be6ad972c3f13d91a6593bd9632cc7b94b9835c4c6280aad"
        ),
        .binaryTarget(
            name: "artiusid_sdk_ios",
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.131/artiusid_sdk_ios.xcframework.zip",
            checksum: "1b1851f79586fb9c38ff2a7a4d98ff1456b06da26ea825781b56c5e5b3ed3bc0"
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
