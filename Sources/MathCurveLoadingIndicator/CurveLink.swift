import DisplayLink
import Foundation

@MainActor
class CurveLink: DisplayLinkDelegate {
    let displayLink: DisplayLink

    typealias SynchronizationUpdate = @MainActor () -> Void
    var onSynchronizationUpdate: SynchronizationUpdate?

    init(context: DisplayLinkContext) {
        displayLink = .init(context: context)
        displayLink.delegate = self
    }

    deinit {}

    func displayLink(_: DisplayLink, didUpdate _: DisplayLinkFrame) {
        onSynchronizationUpdate?()
    }
}
