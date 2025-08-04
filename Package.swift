// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ArtiusIDSDK",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "ArtiusIDSDK",
            targets: ["ArtiusIDSDK"]
        ),
    ],
    dependencies: [
        // ✅ OpenSSL integrated via SwiftPM - no consumer setup required
        .package(url: "https://github.com/krzyzanowskim/OpenSSL.git", from: "3.3.3001")
    ],
    targets: [
        .binaryTarget(
            name: "ArtiusIDSDK",
            url: "https://github.com/artiusID/sdk/releases/download/v1.0.41/ArtiusIDSDK.xcframework.zip",
            checksum: "0dfd039de2de3433e5542c6735f7c3d092f244c0d9fae913fcbafb306281ba85"
        )
    ]
)
