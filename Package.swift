// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "glyph-studio",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "GLYPHCore",
            targets: ["GLYPHCore"]
        ),
        .executable(
            name: "glyph",
            targets: ["glyph-cli"]
        )
    ],
    targets: [
        .target(
            name: "GLYPHCore",
            path: "Sources/GLYPHCore",
            resources: [
                .process("Resources")
            ]
        ),
        .executableTarget(
            name: "glyph-cli",
            dependencies: ["GLYPHCore"],
            path: "Sources/glyph-cli"
        ),
        .testTarget(
            name: "GLYPHCoreTests",
            dependencies: ["GLYPHCore"],
            path: "Tests/GLYPHCoreTests"
        )
    ]
)
