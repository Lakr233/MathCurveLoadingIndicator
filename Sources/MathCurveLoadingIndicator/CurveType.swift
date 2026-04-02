import CoreGraphics
import Foundation

public enum CurveType: Int, CaseIterable, Sendable {
    case originalThinking = 0
    case roseOrbit
    case lissajousDrift
    case lemniscateBloom
    case hypotrochoidLoop
    case butterflyPhase
    case cardioidGlow
    case spiralSearch
    case nautilusDrift
    case astroidStar
    case superellipseMorph
    case hypocycloidCrest
    case cassiniBloom
    case nephroidTide
    case deltoidDrift
    case epitrochoidHalo
    case fourierFlow

    public var name: String {
        switch self {
        case .originalThinking: "Original Thinking"
        case .roseOrbit: "Rose Orbit"
        case .lissajousDrift: "Lissajous Drift"
        case .lemniscateBloom: "Lemniscate Bloom"
        case .hypotrochoidLoop: "Hypotrochoid Loop"
        case .butterflyPhase: "Butterfly Phase"
        case .cardioidGlow: "Cardioid Glow"
        case .spiralSearch: "Spiral Search"
        case .nautilusDrift: "Nautilus Drift"
        case .astroidStar: "Astroid Star"
        case .superellipseMorph: "Superellipse Morph"
        case .hypocycloidCrest: "Hypocycloid Crest"
        case .cassiniBloom: "Cassini Bloom"
        case .nephroidTide: "Nephroid Tide"
        case .deltoidDrift: "Deltoid Drift"
        case .epitrochoidHalo: "Epitrochoid Halo"
        case .fourierFlow: "Fourier Flow"
        }
    }

    public var shouldRotate: Bool {
        self == .originalThinking
    }

    public var defaultParameters: CurveParameters {
        switch self {
        case .originalThinking:
            CurveParameters(
                particleCount: 64, trailSpan: 0.38, durationMs: 4600,
                pulseDurationMs: 4200, rotationDurationMs: 28000, strokeWidth: 5.5
            )
        case .roseOrbit:
            CurveParameters(
                particleCount: 72, trailSpan: 0.42, durationMs: 5200,
                pulseDurationMs: 4600, rotationDurationMs: 30000, strokeWidth: 5.2
            )
        case .lissajousDrift:
            CurveParameters(
                particleCount: 68, trailSpan: 0.34, durationMs: 6000,
                pulseDurationMs: 5400, rotationDurationMs: 36000, strokeWidth: 4.7
            )
        case .lemniscateBloom:
            CurveParameters(
                particleCount: 70, trailSpan: 0.4, durationMs: 5600,
                pulseDurationMs: 5000, rotationDurationMs: 34000, strokeWidth: 4.8
            )
        case .hypotrochoidLoop:
            CurveParameters(
                particleCount: 82, trailSpan: 0.46, durationMs: 7600,
                pulseDurationMs: 6200, rotationDurationMs: 42000, strokeWidth: 4.6
            )
        case .butterflyPhase:
            CurveParameters(
                particleCount: 88, trailSpan: 0.32, durationMs: 9000,
                pulseDurationMs: 7000, rotationDurationMs: 50000, strokeWidth: 4.4
            )
        case .cardioidGlow:
            CurveParameters(
                particleCount: 72, trailSpan: 0.36, durationMs: 6200,
                pulseDurationMs: 5200, rotationDurationMs: 36000, strokeWidth: 4.9
            )
        case .spiralSearch:
            CurveParameters(
                particleCount: 86, trailSpan: 0.28, durationMs: 7800,
                pulseDurationMs: 6800, rotationDurationMs: 44000, strokeWidth: 4.3
            )
        case .nautilusDrift:
            CurveParameters(
                particleCount: 90, trailSpan: 0.24, durationMs: 8600,
                pulseDurationMs: 7000, rotationDurationMs: 46000, strokeWidth: 4.1
            )
        case .astroidStar:
            CurveParameters(
                particleCount: 68, trailSpan: 0.41, durationMs: 5400,
                pulseDurationMs: 4800, rotationDurationMs: 32000, strokeWidth: 5.0
            )
        case .superellipseMorph:
            CurveParameters(
                particleCount: 80, trailSpan: 0.37, durationMs: 6400,
                pulseDurationMs: 5600, rotationDurationMs: 38000, strokeWidth: 4.6
            )
        case .hypocycloidCrest:
            CurveParameters(
                particleCount: 72, trailSpan: 0.39, durationMs: 5600,
                pulseDurationMs: 5000, rotationDurationMs: 32000, strokeWidth: 4.8
            )
        case .cassiniBloom:
            CurveParameters(
                particleCount: 84, trailSpan: 0.35, durationMs: 6600,
                pulseDurationMs: 5600, rotationDurationMs: 36000, strokeWidth: 4.5
            )
        case .nephroidTide:
            CurveParameters(
                particleCount: 78, trailSpan: 0.41, durationMs: 6200,
                pulseDurationMs: 5400, rotationDurationMs: 34000, strokeWidth: 4.7
            )
        case .deltoidDrift:
            CurveParameters(
                particleCount: 66, trailSpan: 0.38, durationMs: 5400,
                pulseDurationMs: 4600, rotationDurationMs: 30000, strokeWidth: 4.9
            )
        case .epitrochoidHalo:
            CurveParameters(
                particleCount: 88, trailSpan: 0.44, durationMs: 7600,
                pulseDurationMs: 6200, rotationDurationMs: 42000, strokeWidth: 4.4
            )
        case .fourierFlow:
            CurveParameters(
                particleCount: 92, trailSpan: 0.31, durationMs: 8400,
                pulseDurationMs: 6800, rotationDurationMs: 44000, strokeWidth: 4.2
            )
        }
    }

    public func point(progress: Double, detailScale: Double) -> CGPoint {
        switch self {
        case .originalThinking:
            let t = progress * .pi * 2
            let x = 7 * cos(t) - 3 * detailScale * cos(7 * t)
            let y = 7 * sin(t) - 3 * detailScale * sin(7 * t)
            return CGPoint(x: 50 + x * 3.9, y: 50 + y * 3.9)

        case .roseOrbit:
            let t = progress * .pi * 2
            let r = 7 - 2.7 * detailScale * cos(7 * t)
            return CGPoint(x: 50 + cos(t) * r * 3.9, y: 50 + sin(t) * r * 3.9)

        case .lissajousDrift:
            let t = progress * .pi * 2
            let amp = 24 + detailScale * 6
            return CGPoint(
                x: 50 + sin(3 * t + .pi / 2) * amp,
                y: 50 + sin(4 * t) * (amp * 0.92)
            )

        case .lemniscateBloom:
            let t = progress * .pi * 2
            let scale = 20 + detailScale * 7
            let denom = 1 + pow(sin(t), 2)
            return CGPoint(
                x: 50 + (scale * cos(t)) / denom,
                y: 50 + (scale * sin(t) * cos(t)) / denom
            )

        case .hypotrochoidLoop:
            let t = progress * .pi * 2
            let bigR = 8.2
            let r = 2.7 + detailScale * 0.45
            let d = 4.8 + detailScale * 1.2
            let x = (bigR - r) * cos(t) + d * cos(((bigR - r) / r) * t)
            let y = (bigR - r) * sin(t) - d * sin(((bigR - r) / r) * t)
            return CGPoint(x: 50 + x * 3.05, y: 50 + y * 3.05)

        case .butterflyPhase:
            let t = progress * .pi * 12
            let s = exp(cos(t)) - 2 * cos(4 * t) - pow(sin(t / 12), 5)
            let scale = 4.6 + detailScale * 0.45
            return CGPoint(x: 50 + sin(t) * s * scale, y: 50 + cos(t) * s * scale)

        case .cardioidGlow:
            let t = progress * .pi * 2
            let a = 8.4 + detailScale * 0.8
            let r = a * (1 - cos(t))
            return CGPoint(x: 50 + cos(t) * r * 2.15, y: 50 + sin(t) * r * 2.15)

        case .spiralSearch:
            let t = progress * .pi * 2
            let angle = t * 4
            let radius = 8 + (1 - cos(t)) * (8.5 + detailScale * 2.4)
            return CGPoint(x: 50 + cos(angle) * radius, y: 50 + sin(angle) * radius)

        case .nautilusDrift:
            let t = progress * .pi * 2
            let angle = t * 3
            let growth = exp(0.32 * sin(t))
            let r = (8.5 + detailScale * 2.1) * growth
            return CGPoint(x: 50 + cos(angle) * r, y: 50 + sin(angle) * r)

        case .astroidStar:
            let t = progress * .pi * 2
            let a = 28 + detailScale * 4
            return CGPoint(x: 50 + a * pow(cos(t), 3), y: 50 + a * pow(sin(t), 3))

        case .superellipseMorph:
            let t = progress * .pi * 2
            let a = 26.0
            let b = 26.0
            let exponent = 2.2 + detailScale * 2.1
            let cosT = cos(t)
            let sinT = sin(t)
            let x = a * copysign(pow(abs(cosT), 2.0 / exponent), cosT)
            let y = b * copysign(pow(abs(sinT), 2.0 / exponent), sinT)
            return CGPoint(x: 50 + x, y: 50 + y)

        case .hypocycloidCrest:
            let t = progress * .pi * 2
            let bigR = 9.6
            let r = 2.4 + detailScale * 0.18
            let x = (bigR - r) * cos(t) + r * cos(((bigR - r) / r) * t)
            let y = (bigR - r) * sin(t) - r * sin(((bigR - r) / r) * t)
            return CGPoint(x: 50 + x * 3.35, y: 50 + y * 3.35)

        case .cassiniBloom:
            let t = progress * .pi * 2
            let a = 13.2 + detailScale * 2.2
            let b = 18.5 + detailScale * 2.8
            let value = sqrt(max(0.0001, pow(b, 4) - pow(a, 4) * pow(sin(2 * t), 2)))
            let r = sqrt(max(0.0001, pow(a, 2) * cos(2 * t) + value))
            return CGPoint(x: 50 + cos(t) * r * 1.45, y: 50 + sin(t) * r * 1.45)

        case .nephroidTide:
            let t = progress * .pi * 2
            let a = 8 + detailScale * 1.1
            let x = a * (3 * cos(t) - cos(3 * t))
            let y = a * (3 * sin(t) - sin(3 * t))
            return CGPoint(x: 50 + x * 1.95, y: 50 + y * 1.95)

        case .deltoidDrift:
            let t = progress * .pi * 2
            let a = 13.5 + detailScale * 1.4
            return CGPoint(
                x: 50 + a * (2 * cos(t) + cos(2 * t)),
                y: 50 + a * (2 * sin(t) - sin(2 * t))
            )

        case .epitrochoidHalo:
            let t = progress * .pi * 2
            let bigR = 5.2
            let r = 2.1 + detailScale * 0.12
            let d = 4.3 + detailScale * 0.9
            let x = (bigR + r) * cos(t) - d * cos(((bigR + r) / r) * t)
            let y = (bigR + r) * sin(t) - d * sin(((bigR + r) / r) * t)
            return CGPoint(x: 50 + x * 3.55, y: 50 + y * 3.55)

        case .fourierFlow:
            let t = progress * .pi * 2
            let mix = 1 + detailScale * 0.16
            let x = 17 * cos(t) + 7.5 * cos(3 * t + 0.6 * mix) + 3.2 * sin(5 * t - 0.4)
            let y = 15 * sin(t) + 8.2 * sin(2 * t + 0.25) - 4.2 * cos(4 * t - 0.5 * mix)
            return CGPoint(x: 50 + x, y: 50 + y)
        }
    }
}
