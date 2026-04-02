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
        .package(url: "https://github.com/Lakr233/MSDisplayLink.git", from: "2.0.8"),
    ],
    targets: [
        .target(
            name: "MathCurveLoadingIndicator",
            dependencies: [
                "MSDisplayLink",
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
