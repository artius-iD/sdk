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
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.5/ArtiusIDSDK.xcframework.zip",
            checksum: "515d76ef2b9d8500b34c3bc0b5f0d0e16a10bc4d9e5b2c81739f70a3c753dfd7"
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
