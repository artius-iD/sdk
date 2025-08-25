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
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.143/OpenSSL.xcframework.zip",
            checksum: "451dc91fd626832f5a395bb55dff09f0a55fde149fde7d842915bf41da4eae56"
        ),
        .binaryTarget(
            name: "artiusid_sdk_ios",
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.143/artiusid_sdk_ios.xcframework.zip",
            checksum: "e1f164b490cc56065d496d2880fbde17a4e6596f1a155d4b1b480c07bfd89000"
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
