import Foundation

#if canImport(UIKit)
    public typealias CurveView = UICurveView
#endif

#if !canImport(UIKit) && canImport(AppKit)
    public typealias CurveView = NSCurveView
#endif
