// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "GlassIconKit",
    platforms: [
        .iOS(.v26),
        .watchOS(.v26)
    ],
    products: [
        .library(
            name: "GlassIconKit",
            targets: ["GlassIconKit"]
        )
    ],
    targets: [
        .target(name: "GlassIconKit")
    ],
    swiftLanguageModes: [.v6]
)
