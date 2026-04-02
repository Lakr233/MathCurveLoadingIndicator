import Foundation
import MSDisplayLink

@MainActor
class CurveLink: DisplayLinkDelegate {
    let displayLink: DisplayLink = .init()

    typealias SynchronizationUpdate = @MainActor () -> Void
    var onSynchronizationUpdate: SynchronizationUpdate?

    init() {
        displayLink.delegatingObject(self)
    }

    deinit {}

    nonisolated func synchronization(context _: DisplayLinkCallbackContext) {
        MainActor.assumeIsolated {
            onSynchronizationUpdate?()
        }
    }
}
