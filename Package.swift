// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "wintund",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(name: "wintund", targets: ["Wintund"])
    ],
    targets: [
        .executableTarget(
            name: "Wintund",
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("ApplicationServices"),
                .linkedFramework("CoreGraphics"),
                .unsafeFlags([
                    "-Xlinker", "-U", "-Xlinker", "_CoreDockGetTileSize",
                    "-Xlinker", "-U", "-Xlinker", "_CoreDockSetTileSize",
                    "-Xlinker", "-U", "-Xlinker", "_CoreDockGetRect",
                    "-Xlinker", "-U", "-Xlinker", "_CoreDockGetOrientationAndPinning",
                    "-Xlinker", "-U", "-Xlinker", "_CoreDockSetOrientationAndPinning"
                ])
            ]
        )
    ]
)
