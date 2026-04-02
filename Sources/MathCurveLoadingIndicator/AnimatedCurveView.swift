import CoreGraphics
import Foundation
import QuartzCore

class AnimatedCurveView: CurveView {
    var curveType: CurveType = .originalThinking {
        didSet {
            if curveType != oldValue {
                parameters = curveType.defaultParameters
                rebuildParticleLayers()
            }
        }
    }

    var parameters: CurveParameters = CurveType.originalThinking.defaultParameters {
        didSet {
            if parameters.particleCount != oldValue.particleCount {
                rebuildParticleLayers()
            }
            backgroundPathLayer.lineWidth = parameters.strokeWidth * currentScale
            updateParticleAppearance()
        }
    }

    var strokeColor: CGColor = .init(gray: 1, alpha: 1) {
        didSet {
            backgroundPathLayer.strokeColor = strokeColor
            for layer in particleLayers {
                layer.backgroundColor = strokeColor
            }
        }
    }

    let startTime: CFTimeInterval = CACurrentMediaTime()
    let phaseOffset: Double = .random(in: 0 ... 1)

    let backgroundPathLayer = CAShapeLayer()
    var particleLayers: [CALayer] = []

    private var currentScale: CGFloat {
        min(bounds.width, bounds.height) / 100.0
    }

    override init() {
        super.init()

        backgroundPathLayer.fillColor = nil
        backgroundPathLayer.strokeColor = strokeColor
        backgroundPathLayer.lineWidth = parameters.strokeWidth
        backgroundPathLayer.lineCap = .round
        backgroundPathLayer.lineJoin = .round
        backgroundPathLayer.opacity = 0.1
        backgroundPathLayer.actions = [
            "path": NSNull(),
            "lineWidth": NSNull(),
            "strokeColor": NSNull(),
            "opacity": NSNull(),
            "position": NSNull(),
            "bounds": NSNull(),
            "frame": NSNull(),
        ]
        contentLayer.addSublayer(backgroundPathLayer)

        rebuildParticleLayers()
    }

    func rebuildParticleLayers() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        for layer in particleLayers {
            layer.removeFromSuperlayer()
        }
        particleLayers.removeAll()

        let count = parameters.particleCount
        for _ in 0 ..< count {
            let layer = CALayer()
            layer.backgroundColor = strokeColor
            layer.actions = [
                "position": NSNull(),
                "bounds": NSNull(),
                "opacity": NSNull(),
                "cornerRadius": NSNull(),
            ]
            contentLayer.addSublayer(layer)
            particleLayers.append(layer)
        }

        CATransaction.commit()
    }

    private func updateParticleAppearance() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        for layer in particleLayers {
            layer.backgroundColor = strokeColor
        }
        CATransaction.commit()
    }

    // MARK: - Frame Update

    override func vsync() {
        let bounds = bounds
        guard bounds.width > 0, bounds.height > 0 else { return }

        let fitSize = min(bounds.width, bounds.height)
        let inset = fitSize * 0.15
        let drawSize = fitSize - inset * 2
        let scale = drawSize / 100.0
        let offsetX = (bounds.width - drawSize) / 2.0
        let offsetY = (bounds.height - drawSize) / 2.0

        let timeMs = (CACurrentMediaTime() - startTime) * 1000
        let duration = parameters.durationMs
        let progress =
            ((timeMs + phaseOffset * duration).truncatingRemainder(dividingBy: duration)) / duration

        let pulseDuration = parameters.pulseDurationMs
        let pulseProgress =
            ((timeMs + phaseOffset * pulseDuration).truncatingRemainder(dividingBy: pulseDuration))
                / pulseDuration
        let pulseAngle = pulseProgress * .pi * 2
        let detailScale = 0.52 + ((sin(pulseAngle + 0.55) + 1) / 2) * 0.48

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        backgroundPathLayer.frame = contentLayer.bounds
        backgroundPathLayer.lineWidth = parameters.strokeWidth * scale

        if curveType.shouldRotate {
            let rotDuration = parameters.rotationDurationMs
            let rotProgress =
                ((timeMs + phaseOffset * rotDuration).truncatingRemainder(dividingBy: rotDuration))
                    / rotDuration
            let angle = -rotProgress * .pi * 2
            contentLayer.transform = CATransform3DMakeRotation(angle, 0, 0, 1)
        } else {
            contentLayer.transform = CATransform3DIdentity
        }

        let path = CGMutablePath()
        let pathSteps = 480
        for i in 0 ... pathSteps {
            let p = Double(i) / Double(pathSteps)
            let pt = curveType.point(progress: p, detailScale: detailScale)
            let x = pt.x * scale + offsetX
            let y = pt.y * scale + offsetY
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        backgroundPathLayer.path = path

        let count = particleLayers.count
        guard count >= 2 else {
            CATransaction.commit()
            return
        }

        for i in 0 ..< count {
            let tailOffset = Double(i) / Double(count - 1)
            let particleProgress = normalizeProgress(progress - tailOffset * parameters.trailSpan)
            let pt = curveType.point(progress: particleProgress, detailScale: detailScale)
            let x = pt.x * scale + offsetX
            let y = pt.y * scale + offsetY

            let fade = pow(1 - tailOffset, 0.56)
            let radius = (0.9 + fade * 2.7) * scale
            let diameter = radius * 2

            let layer = particleLayers[i]
            layer.bounds = CGRect(x: 0, y: 0, width: diameter, height: diameter)
            layer.position = CGPoint(x: x, y: y)
            layer.cornerRadius = radius
            layer.opacity = Float(0.04 + fade * 0.96)
        }

        CATransaction.commit()
    }

    private func normalizeProgress(_ progress: Double) -> Double {
        ((progress.truncatingRemainder(dividingBy: 1)) + 1).truncatingRemainder(dividingBy: 1)
    }
}
