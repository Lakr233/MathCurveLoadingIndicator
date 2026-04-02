import SwiftUI

@MainActor
struct AnimatedCurveViewRepresentable {
    var curveType: CurveType
    var parameters: CurveParameters
    var color: Color

    func updateView(_ view: AnimatedCurveView) {
        view.curveType = curveType
        view.parameters = parameters
        #if canImport(UIKit)
            view.strokeColor = UIColor(color).cgColor
        #elseif canImport(AppKit)
            view.strokeColor =
                NSColor(color).usingColorSpace(.sRGB)?.cgColor ?? CGColor(gray: 1, alpha: 1)
        #endif
    }
}

#if canImport(UIKit)
    import UIKit

    extension AnimatedCurveViewRepresentable: UIViewRepresentable {
        func makeUIView(context _: Context) -> AnimatedCurveView {
            let view = AnimatedCurveView()
            updateView(view)
            return view
        }

        func updateUIView(_ uiView: AnimatedCurveView, context _: Context) {
            updateView(uiView)
        }
    }
#endif

#if !canImport(UIKit) && canImport(AppKit)
    import AppKit

    extension AnimatedCurveViewRepresentable: NSViewRepresentable {
        func makeNSView(context _: Context) -> AnimatedCurveView {
            let view = AnimatedCurveView()
            updateView(view)
            return view
        }

        func updateNSView(_ nsView: AnimatedCurveView, context _: Context) {
            updateView(nsView)
        }
    }
#endif
