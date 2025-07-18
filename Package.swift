// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ArtiusIDSDK",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "ArtiusIDSDK", targets: ["ArtiusIDSDKWrapper"]),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "11.9.0"),
        .package(url: "https://github.com/krzyzanowskim/OpenSSL.git", from: "3.3.2000")
    ],
    targets: [
        .binaryTarget(
            name: "artiusid_sdk_ios",
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.13/ArtiusIDSDK.xcframework.zip",
            checksum: "ecb388dfc475a435e84a295cd2ad7716c42c119e5bf2c46ca62ba98b8505221a"
        ),
        .target(
            name: "ArtiusIDSDKWrapper",
            dependencies: [
                "artiusid_sdk_ios",
                .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                .product(name: "OpenSSL", package: "OpenSSL")
            ],
            path: "Sources/ArtiusIDSDKWrapper"
        )
    ]
)
