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
        .executableTarget(name: "Wintund")
    ]
)
