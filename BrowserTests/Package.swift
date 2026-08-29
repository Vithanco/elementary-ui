// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "BrowserTests",
    platforms: [.macOS(.v15)],
    dependencies: [
        .package(name: "elementary-ui", path: "../"),
        .package(url: "https://github.com/swiftwasm/JavaScriptKit", from: "0.58.0"),
    ],
    targets: [
        .executableTarget(
            name: "BrowserTests",
            dependencies: [
                .product(name: "ElementaryUI", package: "elementary-ui")
            ]
        )
    ],
    swiftLanguageModes: [.v5]
)
