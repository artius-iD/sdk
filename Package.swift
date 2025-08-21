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
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.128/OpenSSL.xcframework.zip",
            checksum: "800dedbd2f810d437570bbe7c477c395cc99be5e4a1b8878d762f1a7d6780a4b"
        ),
        .binaryTarget(
            name: "artiusid_sdk_ios",
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.128/artiusid_sdk_ios.xcframework.zip",
            checksum: "0ad59d067882ce564bf10d3cb3d5bc04a21d57891bc56503529a9cb61dc604e6"
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
