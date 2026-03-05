// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ArtiusIDSampleApp",
    platforms: [.iOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/artius-iD/sdk.git", from: "2.0.0")
    ],
    targets: [
        .executableTarget(
            name: "ArtiusIDSampleApp",
            dependencies: [
                .product(name: "ArtiusIDSDK", package: "sdk")
            ],
            path: "ArtiusIDSampleApp",
            sources: [
                "SampleApp.swift",
                "Views",
                "Models",
                "Config",
                "Theme",
                "Utilities",
                "Services"
            ],
            resources: [
                .process("Assets.xcassets"),
                .process("Resources")
            ]
        )
    ]
)
