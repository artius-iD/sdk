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
            name: "ArtiusIDSDK",
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.20/ArtiusIDSDK.xcframework.zip",
            checksum: "8c3dc28bdb1f0c20ac7303d599e69d8bf3618bb0aa73286c038099f21c6b8d3b"
        ),
        .target(
            name: "ArtiusIDSDKWrapper",
            dependencies: [
                "ArtiusIDSDK",
                .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                .product(name: "OpenSSL", package: "OpenSSL")
            ],
            path: "Sources/ArtiusIDSDKWrapper"
        )
    ]
)
