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
                    "-Wl,-U,_CoreDockGetTileSize",
                    "-Wl,-U,_CoreDockSetTileSize",
                    "-Wl,-U,_CoreDockGetRect",
                    "-Wl,-U,_CoreDockGetOrientationAndPinning",
                    "-Wl,-U,_CoreDockSetOrientationAndPinning"
                ])
            ]
        )
    ]
)
