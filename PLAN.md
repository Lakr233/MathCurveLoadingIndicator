# MathCurveLoadingIndicator — Implementation Plan

## Context

Build a Swift package that renders 17 mathematical curve-based loading animations on all Apple platforms (iOS 15+, macOS 12+, tvOS 15+, visionOS 1+, Mac Catalyst 15+). The architecture mirrors ColorfulX's platform abstraction pattern exactly — using `canImport(UIKit)` then `canImport(AppKit)`, DisplayLink-driven vsync, and designated platform views. Rendering uses CAShapeLayer + Core Graphics (no Metal needed for lightweight curve paths). All 17 curve formulas are ported from the JS reference implementation.

## File Structure

```
Sources/MathCurveLoadingIndicator/
├── PlatformCheck.swift                 # Compile gate
├── CurveView.swift                     # Platform typealias
├── CurveView+UIKit.swift               # UICurveView (UIView)
├── CurveView+AppKit.swift              # NSCurveView (NSView)
├── CurveLink.swift                     # DisplayLink driver (@MainActor)
├── AnimatedCurveView.swift             # Animation controller (internal)
├── AnimatedCurveView+Update.swift      # Per-frame render logic
├── AnimatedCurveView+SwiftUI.swift     # UIViewRepresentable/NSViewRepresentable
├── MathCurveLoadingView.swift          # Public SwiftUI API (sole public surface)
├── CurveType.swift                     # Enum of 17 math curves
└── CurveParameters.swift               # Animation config struct with validation

Scripts/
└── test.build.sh                       # 8-platform build + test validation

.github/workflows/
└── swift.yml                           # CI workflow

Tests/MathCurveLoadingIndicatorTests/
└── MathCurveLoadingIndicatorTests.swift # Unit tests
```

## Phase 1: Package Foundation

### 1.1 — Update `Package.swift`
- **File:** `Package.swift`
- Add `platforms`: `.iOS(.v15)`, `.macOS(.v12)`, `.macCatalyst(.v15)`, `.tvOS(.v15)`, `.visionOS(.v1)`
- Add dependency: `MSDisplayLink` from `https://github.com/Lakr233/MSDisplayLink.git`, from `"2.0.8"`
- Add `swiftSettings: [.swiftLanguageMode(.v6)]` to the target
- Keep swift-tools-version at 6.2

### 1.2 — Delete placeholder source
- Remove `Sources/MathCurveLoadingIndicator/MathCurveLoadingIndicator.swift`

## Phase 2: Platform Abstraction Layer

### 2.1 — `PlatformCheck.swift`
- `#if !canImport(UIKit) && !canImport(AppKit)` → `#error("Unsupported Platform")`
- Exact mirror of `References/ColorfulX/Sources/ColorfulX/PlatformCheck.swift`

### 2.2 — `CurveLink.swift` (DisplayLink driver)
- `@MainActor class CurveLink: DisplayLinkDelegate`
- Owns `DisplayLink` from MSDisplayLink
- Provides `onSynchronizationUpdate: (@MainActor () -> Void)?` callback
- `synchronization(context:)` uses `MainActor.assumeIsolated` (same as ColorfulX `MetalLink.swift:102-106`)
- **No Metal** — just the display link and callback, nothing else

### 2.3 — `CurveView.swift` (typealias)
- `#if canImport(UIKit)` → `public typealias CurveView = UICurveView`
- `#if !canImport(UIKit) && canImport(AppKit)` → `public typealias CurveView = NSCurveView`
- Mirrors `References/ColorfulX/Sources/ColorfulX/MetalView.swift` exactly

### 2.4 — `CurveView+UIKit.swift`
- `open class UICurveView: UIView`
- Owns a **container `CALayer`** (contentLayer) that holds all sublayers (background path + particles). Rotation is applied to this single container, mirroring the JS group transform at `main.js:597`
- Owns `CurveLink?`
- `qualifiedForUpdate` flag with same checks as ColorfulX `MetalView+UIKit.swift`:
  - `window != nil`, `frame.width > 0`, `frame.height > 0`, `alpha > 0`, `!isHidden`
- Same property overrides: `frame`, `bounds`, `center`, `isHidden`, `alpha` — all with `CATransaction` wrapping
- Same lifecycle: `didMoveToWindow()`, `didMoveToSuperview()`, `layoutSubviews()`
- `vsync()` stub called from `curveLink.onSynchronizationUpdate`
- Disable implicit animations on container layer via NSNull actions dict

### 2.5 — `CurveView+AppKit.swift`
- `open class NSCurveView: NSView`
- Same container layer pattern as UIKit
- AppKit-specific overrides:
  - `wantsLayer = true`, `alphaValue` instead of `alpha`
  - `viewDidMoveToWindow()` instead of `didMoveToWindow()`
  - `layout()` instead of `layoutSubviews()`
- Mirrors `References/ColorfulX/Sources/ColorfulX/MetalView+AppKit.swift`

## Phase 3: Data Model

### 3.1 — `CurveParameters.swift`
- `public struct CurveParameters: Sendable, Equatable`
- Fields: `particleCount: Int`, `trailSpan: Double`, `durationMs: Double`, `pulseDurationMs: Double`, `rotationDurationMs: Double`, `strokeWidth: Double`
- **Validation via clamping in init** — clamp all values to safe ranges matching JS `CONTROL_DEFS` at `main.js:19-26`:
  - `particleCount`: clamped to `2...140` (minimum 2 to avoid degenerate trail math at `main.js:573`)
  - `trailSpan`: clamped to `0.01...0.99`
  - `durationMs`: clamped to `100...60000` (never zero — prevents divide-by-zero in modulo at `main.js:589`)
  - `pulseDurationMs`: clamped to `100...60000` (same reason — used in pulse angle at `main.js:589`)
  - `rotationDurationMs`: clamped to `100...120000`
  - `strokeWidth`: clamped to `0.5...20.0`
- **No default values in init** — the only source of defaults is `CurveType.defaultParameters`, avoiding duplicate default sources

### 3.2 — `CurveType.swift`
- `public enum CurveType: Int, CaseIterable, Sendable` with 17 cases:
  1. `originalThinking` — Rose Trail variant
  2. `roseOrbit` — r = cos(kθ)
  3. `lissajousDrift` — x = sin(at), y = sin(bt)
  4. `lemniscateBloom` — Bernoulli Lemniscate
  5. `hypotrochoidLoop` — Inner Spirograph
  6. `butterflyPhase` — Butterfly Curve
  7. `cardioidGlow` — Heart-shaped
  8. `spiralSearch` — Archimedean Spiral
  9. `nautilusDrift` — Logarithmic Spiral
  10. `astroidStar` — 4-pointed star
  11. `superellipseMorph` — Rounded square morphing
  12. `hypocycloidCrest` — Multi-pointed inner curve
  13. `cassiniBloom` — Cassini Oval
  14. `nephroidTide` — Kidney-shaped
  15. `deltoidDrift` — 3-pointed inner curve
  16. `epitrochoidHalo` — Ornate wheel curve
  17. `fourierFlow` — Composite sine/cosine

- Each case provides:
  - `func point(progress: Double, detailScale: Double) -> CGPoint` — direct port from JS `main.js`. Coordinate space is 0-100 centered at (50,50)
  - `var name: String` — human-readable name
  - `var shouldRotate: Bool` — only `.originalThinking` is `true`
  - `var defaultParameters: CurveParameters` — **sole source of default values** (CurveParameters init has no defaults)

- **Pitfalls to handle:**
  - Superellipse: `copysign(pow(abs(cosT), 2.0/exponent), cosT)` to avoid NaN
  - Cassini: `max(0.0001, ...)` before `sqrt` to avoid domain errors
  - Butterfly: uses `progress * .pi * 12` not `* 2`

## Phase 4: Animation View

### 4.1 — `AnimatedCurveView.swift`
- **`class AnimatedCurveView: CurveView`** (internal, not open — `MathCurveLoadingView` is the sole public surface)
- Properties: `curveType`, `parameters`, `strokeColor: CGColor`
- `startTime: CFTimeInterval` — set to `CACurrentMediaTime()` at init (monotonic clock, consistent with `performance.now()` in JS and ColorfulX's `AnimatedMulticolorGradientView.swift:85`)
- `phaseOffset: Double` — `Double.random(in: 0...1)` for visual variety
- Container layer (from CurveView) holds:
  - `backgroundPathLayer: CAShapeLayer` — full curve at 0.1 opacity
  - `particleLayers: [CAShapeLayer]` — N circle layers
- `rebuildParticleLayers()` — creates `particleCount` small circle layers with `cornerRadius`
- Rotation applied as `CATransform3D` on the **container layer only** (mirrors JS group transform at `main.js:597`), not spread across individual path/particle updates

### 4.2 — `AnimatedCurveView+Update.swift`
- `override func vsync()` — the per-frame update
- **Coordinate mapping** (complete formula):
  1. `let fitSize = min(bounds.width, bounds.height)`
  2. `let scale = fitSize / 100.0`
  3. `let offsetX = (bounds.width - fitSize) / 2.0`
  4. `let offsetY = (bounds.height - fitSize) / 2.0`
  5. Map each point: `CGPoint(x: pt.x * scale + offsetX, y: pt.y * scale + offsetY)`
  6. `strokeWidth` and particle radius also scaled by `scale` factor
- Algorithm (direct port of JS `renderInstance` at `main.js:849-867`):
  1. Compute elapsed time via `CACurrentMediaTime() - startTime`, convert to ms
  2. Compute `progress` (0→1): `((timeMs + phaseOffset * durationMs).truncatingRemainder(dividingBy: durationMs)) / durationMs`
  3. Compute `detailScale` (breathing): `0.52 + ((sin(pulseAngle + 0.55) + 1) / 2) * 0.48` (from `main.js:589-595`)
  4. Compute rotation angle and apply to container layer's `transform` (only when `shouldRotate`)
  5. Build background path (480 line segments along entire curve)
  6. Update each particle layer's `position` and `opacity` (decreasing along trail)
  7. All mutations in `CATransaction` with disabled actions

## Phase 5: SwiftUI Wrapper

### 5.1 — `AnimatedCurveView+SwiftUI.swift`
- `@MainActor struct AnimatedCurveViewRepresentable` (internal)
- `#if canImport(UIKit)` → `UIViewRepresentable` with `makeUIView`/`updateUIView`
- `#if !canImport(UIKit) && canImport(AppKit)` → `NSViewRepresentable` with `makeNSView`/`updateNSView`
- Shared `updateView(_:)` method pushes curveType, parameters, strokeColor
- Color conversion: `UIColor(color).cgColor` on UIKit, `NSColor(color).usingColorSpace(.sRGB)?.cgColor ?? CGColor(gray: 1, alpha: 1)` on AppKit

### 5.2 — `MathCurveLoadingView.swift`
- `public struct MathCurveLoadingView: View` — **sole public API surface**
- Init: `curveType: CurveType = .originalThinking`, `parameters: CurveParameters? = nil` (nil uses `curveType.defaultParameters`), `color: Color = .primary`
- Body wraps `AnimatedCurveViewRepresentable` with `.contentShape(Rectangle())`

## Phase 6: CI / Build Scripts

### 6.1 — `Scripts/test.build.sh`
- Port from `References/ColorfulX/Scripts/test.build.sh`
- Use `xcodebuild` with `-scheme MathCurveLoadingIndicator` (no workspace needed for SPM package)
- Same 8 platform destinations:
  - `generic/platform=macOS`
  - `generic/platform=macOS,variant=Mac Catalyst`
  - `generic/platform=iOS`
  - `generic/platform=iOS Simulator`
  - `generic/platform=tvOS`
  - `generic/platform=tvOS Simulator`
  - `generic/platform=xrOS`
  - `generic/platform=xrOS Simulator`
- Same `xcbeautify -qq`, `PIPESTATUS`, `CODE_SIGNING_ALLOWED=NO`
- **Add `swift test` step** before the xcodebuild loop to run unit tests (since we have real tests, unlike ColorfulX's build-only CI)

### 6.2 — `.github/workflows/swift.yml`
- Port from `References/ColorfulX/.github/workflows/swift.yml`
- `runs-on: macos-26`, checkout v4, run `./Scripts/test.build.sh`
- Triggers: push to main, PRs to main

## Phase 7: Tests

### 7.1 — Update `Tests/MathCurveLoadingIndicatorTests/MathCurveLoadingIndicatorTests.swift`
- Uses Swift Testing framework (`import Testing`)
- Tests:
  1. **All curve types return finite points** — iterate `CurveType.allCases`, verify `point(progress:detailScale:)` returns finite `x` and `y` (`.isFinite`). Use a loose envelope (e.g., -50...150) instead of strict 0-100 — curves like Nephroid Tide (`main.js:394`) extend beyond the 0-100 box
  2. **Curve points vary with progress** — verify `point(progress: 0)` differs from `point(progress: 0.5)` for all curves
  3. **Default parameters are in valid ranges** — verify each curve's `defaultParameters` has `particleCount >= 2`, positive durations, `trailSpan` in 0...1
  4. **Detail scale affects curve shape** — verify `detailScale: 0.52` produces different points than `detailScale: 1.0`
  5. **CurveParameters clamping works** — verify that out-of-range values are clamped (e.g., `particleCount: 0` → `2`, `durationMs: 0` → `100`)

## Implementation Order

| Step | Files | Depends On | Verify |
|------|-------|------------|--------|
| 1.1 | `Package.swift` | — | `swift package resolve` |
| 1.2 | Delete placeholder | — | — |
| 2.1 | `PlatformCheck.swift` | — | Compiles |
| 2.2 | `CurveLink.swift` | MSDisplayLink | Compiles |
| 2.3-2.5 | `CurveView*.swift` (3 files) | CurveLink | `swift build` |
| 3.1-3.2 | `CurveParameters.swift`, `CurveType.swift` | — | Unit tests |
| 4.1-4.2 | `AnimatedCurveView*.swift` (2 files) | Phase 2+3 | `swift build` |
| 5.1-5.2 | SwiftUI wrapper (2 files) | Phase 4 | `swift build` |
| 7.1 | Tests | Phase 3 | `swift test` |
| 6.1-6.2 | Scripts + CI | All source | 8-platform build + test |

## Key Design Decisions

1. **CAShapeLayer, not Metal** — Math curve paths with ~92 particles at 60fps are trivially within Core Animation budget
2. **Individual particle layers** — JS renders each particle as independent `<circle>` with its own opacity; no single-path alternative supports per-segment opacity
3. **Container layer for rotation** — Single `CALayer` holds background path + all particles; rotation transform applied once to this container (mirrors JS group transform at `main.js:597`), simpler than spreading rotation across individual updates
4. **JS 0-100 coordinate space preserved** in `CurveType.point()` for direct traceability; view layer maps to pixels with proper centering offsets and scale factor applied to strokeWidth/particle radius too
5. **MSDisplayLink** — Same vsync driver as ColorfulX, monotonic timing via `CACurrentMediaTime()`
6. **`canImport` order** — `#if canImport(UIKit)` first, then `#if !canImport(UIKit) && canImport(AppKit)` — matches ColorfulX exactly
7. **Swift 6 concurrency** — `@MainActor` on CurveLink, views inherit from UIView/NSView, value types are `Sendable`
8. **Single source of defaults** — `CurveType.defaultParameters` is the only place defaults live; `CurveParameters.init` has no default arguments, only clamping
9. **Internal AnimatedCurveView** — Not `open`, not public. `MathCurveLoadingView` is the sole public API surface
10. **Validated parameters** — `CurveParameters` clamps on init to prevent divide-by-zero and degenerate trail math

## Verification

1. `swift build` — compiles on macOS
2. `swift test` — all unit tests pass (curve math, parameter clamping, point finiteness)
3. `./Scripts/test.build.sh` — builds on all 8 platform destinations + runs tests
4. Visual: `MathCurveLoadingView(curveType: .butterflyPhase)` renders animated curve in SwiftUI preview
