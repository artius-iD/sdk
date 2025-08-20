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
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.120/artiusid_sdk_ios.xcframework.zip",
            checksum: "1eba113956a5dd06bfa196dc860fc3a269d09b2e9fdfe1f109717c031a469bd6"
         ),
        .binaryTarget(
            name: "artiusid_sdk_ios",
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.93/artiusid_sdk_ios.xcframework.zip",
            checksum: "a68c094d66bcbd90ed5b432b478f5098a252d8c06760533cbbc20655f04453fc"
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
