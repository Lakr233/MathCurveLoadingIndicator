# MathCurveLoadingIndicator

Beautiful mathematical curve loading animations for all Apple platforms.

17 parametric curves rendered as particle trails using Core Animation, driven by display-link vsync.

## Curves

Original Thinking, Rose Orbit, Lissajous Drift, Lemniscate Bloom, Hypotrochoid Loop, Butterfly Phase, Cardioid Glow, Spiral Search, Nautilus Drift, Astroid Star, Superellipse Morph, Hypocycloid Crest, Cassini Bloom, Nephroid Tide, Deltoid Drift, Epitrochoid Halo, Fourier Flow.

## Platform Support

iOS 15+ / macOS 12+ / Mac Catalyst 15+ / tvOS 15+ / visionOS 1+

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Lakr233/MathCurveLoadingIndicator.git", from: "1.0.0"),
]
```

## Usage

```swift
import MathCurveLoadingIndicator

// Default
MathCurveLoadingView()

// Pick a curve
MathCurveLoadingView(curveType: .butterflyPhase)

// Customize everything
MathCurveLoadingView(
    curveType: .lissajousDrift,
    parameters: CurveParameters(
        particleCount: 92,
        trailSpan: 0.45,
        durationMs: 5000,
        pulseDurationMs: 4000,
        rotationDurationMs: 30000,
        strokeWidth: 4.0
    ),
    color: .blue
)
```

## License

MIT License. Copyright (c) 2025 Lakr233.

---

*Made with mathematical joy.*
