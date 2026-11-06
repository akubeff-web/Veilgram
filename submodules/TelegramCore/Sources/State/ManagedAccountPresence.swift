import Foundation
internal import TelegramApi
import Postbox
import SwiftSignalKit
import MtProtoKit

private typealias SignalKitTimer = SwiftSignalKit.Timer


private final class AccountPresenceManagerImpl {
    private let queue: Queue
    private let network: Network
    let isPerformingUpdate = ValuePromise<Bool>(false, ignoreRepeated: true)
    
    private var shouldKeepOnlinePresenceDisposable: Disposable?
    private let currentRequestDisposable = MetaDisposable()
    private var onlineTimer: SignalKitTimer?
    
    private var wasOnline: Bool = false
    private var wasHidden: Bool = false
    
    init(queue: Queue, shouldKeepOnlinePresence: Signal<Bool, NoError>, network: Network) {
        self.queue = queue
        self.network = network
        
        // Veilgram: Always Online keeps the status while the app runs at all, and a hidden
        // status sends nothing, so neither the 30 s refresh nor "offline" (which would move
        // "last seen" to now) goes out.
        let veilgramState = VeilgramSettings.updated
        |> map { _ -> (alwaysOnline: Bool, hidden: Bool) in
            return (VeilgramSettings.alwaysOnline, VeilgramSettings.ghostOnline)
        }
        self.shouldKeepOnlinePresenceDisposable = (combineLatest(shouldKeepOnlinePresence, veilgramState)
        |> map { value, veilgram -> (Bool, Bool) in
            return (value || veilgram.alwaysOnline, veilgram.hidden)
        }
        |> distinctUntilChanged(isEqual: { $0 == $1 })
        |> deliverOn(self.queue)).start(next: { [weak self] value, hidden in
            guard let `self` = self else {
                return
            }
            if self.wasOnline != value || self.wasHidden != hidden {
                let wasVisiblyOnline = self.wasOnline && !self.wasHidden
                self.wasOnline = value
                self.wasHidden = hidden
                if hidden {
                    self.onlineTimer?.invalidate()
                    self.onlineTimer = nil
                    if wasVisiblyOnline {
                        // Hiding while shown online: end the online status now.
                        self.sendStatus(offline: true)
                    } else {
                        self.currentRequestDisposable.set(nil)
                    }
                } else {
                    self.updatePresence(value)
                }
            }
        })
    }
    
    deinit {
        assert(self.queue.isCurrent())
        self.shouldKeepOnlinePresenceDisposable?.dispose()
        self.currentRequestDisposable.dispose()
        self.onlineTimer?.invalidate()
    }
    
    private func updatePresence(_ isOnline: Bool) {
        if isOnline {
            let timer = SignalKitTimer(timeout: 30.0, repeat: false, completion: { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.updatePresence(true)
            }, queue: self.queue)
            self.onlineTimer = timer
            timer.start()
        } else {
            self.onlineTimer?.invalidate()
            self.onlineTimer = nil
        }
        self.sendStatus(offline: !isOnline)
    }
    
    private func sendStatus(offline: Bool) {
        let request = self.network.request(Api.functions.account.updateStatus(offline: offline ? .boolTrue : .boolFalse))
        self.isPerformingUpdate.set(true)
        self.currentRequestDisposable.set((request
        |> `catch` { _ -> Signal<Api.Bool, NoError> in
            return .single(.boolFalse)
        }
        |> deliverOn(self.queue)).start(completed: { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.isPerformingUpdate.set(false)
        }))
    }
}

/// Veilgram: the server shows the sender online after every sent message. With the online status
/// hidden, end it right away. Several messages in a row send one request per account.
private let veilgramHideOnlineDisposables = Atomic<[ObjectIdentifier: MetaDisposable]>(value: [:])

func veilgramHideOnlineAfterSending(network: Network) {
    guard VeilgramSettings.ghostOnline else {
        return
    }
    let key = ObjectIdentifier(network)
    let disposable = veilgramHideOnlineDisposables.modify { current in
        var current = current
        if current[key] == nil {
            current[key] = MetaDisposable()
        }
        return current
    }[key]!
    disposable.set((Signal<Api.Bool, MTRpcError>.complete()
    |> delay(1.0, queue: Queue.concurrentDefaultQueue())
    |> then(network.request(Api.functions.account.updateStatus(offline: .boolTrue)))).start())
}

private let veilgramRestoreOnlineDisposables = Atomic<[ObjectIdentifier: MetaDisposable]>(value: [:])

/// Veilgram: with Always Online, answer the account going offline (another session logging off)
/// by going online again.
func veilgramRestoreOnlineStatus(network: Network) {
    guard VeilgramSettings.alwaysOnline else {
        return
    }
    let key = ObjectIdentifier(network)
    let disposable = veilgramRestoreOnlineDisposables.modify { current in
        var current = current
        if current[key] == nil {
            current[key] = MetaDisposable()
        }
        return current
    }[key]!
    disposable.set(network.request(Api.functions.account.updateStatus(offline: .boolFalse)).start())
}

final class AccountPresenceManager {
    private let queue = Queue()
    private let impl: QueueLocalObject<AccountPresenceManagerImpl>
    
    init(shouldKeepOnlinePresence: Signal<Bool, NoError>, network: Network) {
        let queue = self.queue
        self.impl = QueueLocalObject(queue: self.queue, generate: {
            return AccountPresenceManagerImpl(queue: queue, shouldKeepOnlinePresence: shouldKeepOnlinePresence, network: network)
        })
    }
    
    func isPerformingUpdate() -> Signal<Bool, NoError> {
        return Signal { subscriber in
            let disposable = MetaDisposable()
            self.impl.with { impl in
                disposable.set(impl.isPerformingUpdate.get().start(next: { value in
                    subscriber.putNext(value)
                }))
            }
            return disposable
        }
    }
}
