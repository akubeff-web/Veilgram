import Foundation
import BackgroundTasks
import SwiftSignalKit

/// Background app refresh: iOS wakes the app now and then (how often depends on how the app is
/// used and on the battery), and it connects for a few seconds to take the updates it missed.
/// A message is only kept after it was deleted if it reached the device before that, and without
/// push notifications (unavailable to a free Apple ID) this is what fetches it while the app is
/// not running.
@available(iOS 13.0, *)
enum VeilgramBackgroundRefresh {
    private static let runDuration: Double = 20.0
    private static let interval: Double = 15.0 * 60.0

    /// Registered under the identifier Info.plist permits: a re-signing tool may rename it along
    /// with the bundle id, and registering any other one throws.
    static var identifier: String? {
        guard let identifiers = Bundle.main.object(forInfoDictionaryKey: "BGTaskSchedulerPermittedIdentifiers") as? [String] else {
            return nil
        }
        return identifiers.first(where: { $0.hasSuffix(".refresh") })
    }

    static func register(wake: @escaping () -> Void) {
        guard let identifier = self.identifier else {
            return
        }
        BGTaskScheduler.shared.register(forTaskWithIdentifier: identifier, using: DispatchQueue.main) { task in
            self.schedule()
            wake()

            var completed = false
            let complete: (Bool) -> Void = { success in
                if !completed {
                    completed = true
                    task.setTaskCompleted(success: success)
                }
            }
            let timer = SwiftSignalKit.Timer(timeout: self.runDuration, repeat: false, completion: {
                complete(true)
            }, queue: Queue.mainQueue())
            timer.start()
            task.expirationHandler = {
                timer.invalidate()
                complete(false)
            }
        }
        self.schedule()
    }

    static func schedule() {
        guard let identifier = self.identifier else {
            return
        }
        let request = BGAppRefreshTaskRequest(identifier: identifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: self.interval)
        try? BGTaskScheduler.shared.submit(request)
    }
}
