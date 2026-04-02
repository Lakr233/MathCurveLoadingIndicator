@testable import MathCurveLoadingIndicator
import Testing

struct CurveTypeTests {
    @Test("All curve types return finite points")
    func allCurveTypesReturnFinitePoints() {
        for curve in CurveType.allCases {
            for progress in stride(from: 0.0, through: 1.0, by: 0.1) {
                let pt = curve.point(progress: progress, detailScale: 0.75)
                #expect(pt.x.isFinite, "Curve \(curve.name) returned non-finite x at progress \(progress)")
                #expect(pt.y.isFinite, "Curve \(curve.name) returned non-finite y at progress \(progress)")
                #expect(
                    (-50 ... 150).contains(pt.x),
                    "Curve \(curve.name) x=\(pt.x) outside loose envelope at progress \(progress)"
                )
                #expect(
                    (-50 ... 150).contains(pt.y),
                    "Curve \(curve.name) y=\(pt.y) outside loose envelope at progress \(progress)"
                )
            }
        }
    }

    @Test("Curve points vary with progress")
    func curvePointsVaryWithProgress() {
        for curve in CurveType.allCases {
            let p0 = curve.point(progress: 0, detailScale: 0.75)
            let p5 = curve.point(progress: 0.5, detailScale: 0.75)
            let differs = p0.x != p5.x || p0.y != p5.y
            #expect(differs, "Curve \(curve.name) produced identical points at progress 0 and 0.5")
        }
    }

    @Test("Default parameters are in valid ranges")
    func defaultParametersAreValid() {
        for curve in CurveType.allCases {
            let p = curve.defaultParameters
            #expect(p.particleCount >= 2, "Curve \(curve.name) particleCount too low: \(p.particleCount)")
            #expect(
                p.particleCount <= 140,
                "Curve \(curve.name) particleCount too high: \(p.particleCount)"
            )
            #expect(
                (0.01 ... 0.99).contains(p.trailSpan),
                "Curve \(curve.name) trailSpan out of range: \(p.trailSpan)"
            )
            #expect(p.durationMs > 0, "Curve \(curve.name) durationMs not positive")
            #expect(p.pulseDurationMs > 0, "Curve \(curve.name) pulseDurationMs not positive")
            #expect(p.rotationDurationMs > 0, "Curve \(curve.name) rotationDurationMs not positive")
            #expect(p.strokeWidth > 0, "Curve \(curve.name) strokeWidth not positive")
        }
    }

    @Test("Detail scale affects curve shape")
    func detailScaleAffectsCurveShape() {
        for curve in CurveType.allCases {
            var foundDifference = false
            for progress in [0.1, 0.15, 0.2, 0.3, 0.37, 0.5, 0.7] {
                let pLow = curve.point(progress: progress, detailScale: 0.52)
                let pHigh = curve.point(progress: progress, detailScale: 1.0)
                if pLow.x != pHigh.x || pLow.y != pHigh.y {
                    foundDifference = true
                    break
                }
            }
            #expect(
                foundDifference,
                "Curve \(curve.name) not affected by detailScale at any tested progress"
            )
        }
    }
}

struct CurveParametersTests {
    @Test("Clamping works for out-of-range values")
    func clampingWorks() {
        let p = CurveParameters(
            particleCount: 0, trailSpan: -1, durationMs: 0,
            pulseDurationMs: 0, rotationDurationMs: 0, strokeWidth: 0
        )
        #expect(p.particleCount == 2)
        #expect(p.trailSpan == 0.01)
        #expect(p.durationMs == 100)
        #expect(p.pulseDurationMs == 100)
        #expect(p.rotationDurationMs == 100)
        #expect(p.strokeWidth == 0.5)
    }

    @Test("Clamping caps high values")
    func clampingCapsHigh() {
        let p = CurveParameters(
            particleCount: 999, trailSpan: 5, durationMs: 999_999,
            pulseDurationMs: 999_999, rotationDurationMs: 999_999, strokeWidth: 100
        )
        #expect(p.particleCount == 140)
        #expect(p.trailSpan == 0.99)
        #expect(p.durationMs == 60000)
        #expect(p.pulseDurationMs == 60000)
        #expect(p.rotationDurationMs == 120_000)
        #expect(p.strokeWidth == 20.0)
    }
}
