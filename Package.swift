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
            name: "OpenSSL",
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.74/OpenSSL.xcframework.zip",
            checksum: "f3794d67fdd1bb8d134118b81f292ebdd6e429d792b39d23cd97c8fec4f1cac4"
        ),
        .binaryTarget(
            name: "ArtiusIDiOSSDKBinary",
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.74/artiusid_sdk_ios.xcframework.zip",
            checksum: "4eb780b7f80ee28ec2c9bc3882b262704a8b8631099e54064920bb36d199bfc7"
        ),
        .target(
            name: "ArtiusIDSDKWrapper",
            dependencies: [
                "ArtiusIDiOSSDKBinary",
                "OpenSSL"
            ],
            path: "Sources/ArtiusIDSDKWrapper"
        )
    ]
)
