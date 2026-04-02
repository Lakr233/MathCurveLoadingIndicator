import Foundation

#if !canImport(UIKit) && canImport(AppKit)

    import AppKit

    open class NSCurveView: NSView {
        var curveLink: CurveLink? = .init()
        let contentLayer = CALayer()
        var qualifiedForUpdate: Bool = true

        init() {
            super.init(frame: .zero)

            wantsLayer = true
            if let layer {
                layer.isOpaque = false
                layer.backgroundColor = NSColor.clear.cgColor
                layer.masksToBounds = true

                contentLayer.masksToBounds = true
                contentLayer.actions = [
                    "position": NSNull(),
                    "bounds": NSNull(),
                    "frame": NSNull(),
                    "transform": NSNull(),
                    "sublayerTransform": NSNull(),
                ]
                layer.addSublayer(contentLayer)

                curveLink?.onSynchronizationUpdate = { [weak self] in
                    self?.vsyncCheckQualificationAndSend()
                }
            }
        }

        @available(*, unavailable)
        public required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        deinit { curveLink = nil }

        func vsync() {}

        private func updateQualificationCheck() {
            qualifiedForUpdate = [
                window != nil,
                frame.width > 0,
                frame.height > 0,
                alphaValue > 0,
                !isHidden,
            ].allSatisfy(\.self)
        }

        override open var frame: NSRect {
            get { super.frame }
            set {
                super.frame = newValue
                updateQualificationCheck()
            }
        }

        override open var isHidden: Bool {
            get { super.isHidden }
            set {
                super.isHidden = newValue
                updateQualificationCheck()
            }
        }

        override open var alphaValue: CGFloat {
            get { super.alphaValue }
            set {
                super.alphaValue = newValue
                updateQualificationCheck()
            }
        }

        override open func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            updateQualificationCheck()
        }

        private func vsyncCheckQualificationAndSend() {
            guard qualifiedForUpdate else { return }
            vsync()
        }

        override open func layout() {
            super.layout()
            updateQualificationCheck()

            CATransaction.begin()
            CATransaction.setDisableActions(true)
            contentLayer.frame = bounds
            CATransaction.commit()
        }
    }
#endif
