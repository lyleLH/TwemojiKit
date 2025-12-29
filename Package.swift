// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "TwemojiKit",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "TwemojiKit",
            targets: ["TwemojiKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/SVGKit/SVGKit.git", from: "3.0.0"),
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.18.10")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "TwemojiKit",
            dependencies: [
                .product(name: "SVGKit", package: "SVGKit"),
                .product(name: "SDWebImage", package: "SDWebImage")
            ],
            path: "Sources",
            resources: [.copy("./Core/twemoji.min.js")]
        )
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
