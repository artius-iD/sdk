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
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.139/OpenSSL.xcframework.zip",
            checksum: "8c58c50c17831f0a1cfb0e02cf0b60c883052e1f1067eb2ee7fd43849f693158"
        ),
        .binaryTarget(
            name: "artiusid_sdk_ios",
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.139/artiusid_sdk_ios.xcframework.zip",
            checksum: "2fa44fdd6f1ee0ac715342fa52512fe395edcf6b0a41dacbe0842d1ea6814bdd"
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
