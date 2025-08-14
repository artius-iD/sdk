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
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.82/OpenSSL.xcframework.zip",
            checksum: "11fd7e135825965b8d25719bb12f764546976743a80a93edab362c01c47a074e"
        ),
        .binaryTarget(
            name: "artiusid_sdk_ios",
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.82/artiusid_sdk_ios.xcframework.zip",
            checksum: "098a93f75ae1e92f19126fa565f257d16306535cb6c4ca97e69975e905186a42"
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
