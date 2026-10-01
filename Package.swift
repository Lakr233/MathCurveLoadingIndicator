// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "MathCurveLoadingIndicator",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .macCatalyst(.v15),
        .tvOS(.v15),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "MathCurveLoadingIndicator", targets: ["MathCurveLoadingIndicator"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Lakr233/DisplayLink.git", from: "3.0.0"),
    ],
    targets: [
        .target(
            name: "MathCurveLoadingIndicator",
            dependencies: [
                "DisplayLink",
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
        .testTarget(
            name: "MathCurveLoadingIndicatorTests",
            dependencies: ["MathCurveLoadingIndicator"]
        ),
    ]
)
