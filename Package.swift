// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "artiusid_sdk_ios",
    platforms: [.iOS(.v13)],
.products: [
    .library(name: "artiusid_sdk_ios", targets: ["ArtiusIDSDKWrapper"]),
    .library(name: "ArtiusIDSDKWrapper", targets: ["ArtiusIDSDKWrapper"]),
],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "OpenSSL",
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.78/OpenSSL.xcframework.zip",
            checksum: "ad0a46d2744967347ff55ba9b65a3c4934324b572ccd92cd07e8f601c0083f69"
        ),
        .binaryTarget(
            name: "artiusid_sdk_ios",
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.78/artiusid_sdk_ios.xcframework.zip",
            checksum: "2c248b40c959f111188b5dfbb9932da27fd041ecc54813df1495a9239595f347"
        ),
        .target(
            name: "ArtiusIDSDKWrapper",
            dependencies: [
                "artiusid_sdk_ios",
                "OpenSSL"
            ],
            path: "Sources/ArtiusIDSDKWrapper"
        )
    ]
)
