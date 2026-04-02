import Foundation

public struct CurveParameters: Sendable, Equatable {
    public var particleCount: Int
    public var trailSpan: Double
    public var durationMs: Double
    public var pulseDurationMs: Double
    public var rotationDurationMs: Double
    public var strokeWidth: Double

    public init(
        particleCount: Int,
        trailSpan: Double,
        durationMs: Double,
        pulseDurationMs: Double,
        rotationDurationMs: Double,
        strokeWidth: Double
    ) {
        self.particleCount = max(2, min(140, particleCount))
        self.trailSpan = max(0.01, min(0.99, trailSpan))
        self.durationMs = max(100, min(60000, durationMs))
        self.pulseDurationMs = max(100, min(60000, pulseDurationMs))
        self.rotationDurationMs = max(100, min(120_000, rotationDurationMs))
        self.strokeWidth = max(0.5, min(20.0, strokeWidth))
    }
}
