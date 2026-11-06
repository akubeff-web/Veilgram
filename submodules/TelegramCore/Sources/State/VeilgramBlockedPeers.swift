import Foundation
import Postbox
import SwiftSignalKit
internal import TelegramApi
import MtProtoKit

/// The peers each account blocked, so their messages can be left out of groups. Loaded once per
/// launch from the server and kept current by blocking and unblocking in the app.
public enum VeilgramBlockedPeers {
    private static let blocked = Atomic<[PeerId: Set<PeerId>]>(value: [:])
    private static let loadStarted = Atomic<Set<PeerId>>(value: Set())

    public static func contains(accountPeerId: PeerId, peerId: PeerId) -> Bool {
        return self.blocked.with { $0[accountPeerId]?.contains(peerId) ?? false }
    }

    static func update(accountPeerId: PeerId, peerIds: [PeerId], isBlocked: Bool) {
        let _ = self.blocked.modify { current in
            var current = current
            var set = current[accountPeerId] ?? Set()
            if isBlocked {
                set.formUnion(peerIds)
            } else {
                set.subtract(peerIds)
            }
            current[accountPeerId] = set
            return current
        }
    }

    /// Starts loading the account's blocked peers unless that already happened in this launch.
    public static func ensureLoaded(account: Account) {
        let accountPeerId = account.peerId
        var isFirst = false
        let _ = self.loadStarted.modify { current in
            var current = current
            isFirst = current.insert(accountPeerId).inserted
            return current
        }
        if !isFirst {
            return
        }
        let _ = self.loadPage(account: account, offset: 0).start()
    }

    private static func loadPage(account: Account, offset: Int32) -> Signal<Never, NoError> {
        let accountPeerId = account.peerId
        return account.network.request(Api.functions.contacts.getBlocked(flags: 0, offset: offset, limit: 200))
        |> map(Optional.init)
        |> `catch` { _ -> Signal<Api.contacts.Blocked?, NoError> in
            return .single(nil)
        }
        |> mapToSignal { result -> Signal<Never, NoError> in
            guard let result else {
                return .complete()
            }
            let blocked: [Api.PeerBlocked]
            var hasMore = false
            switch result {
            case let .blocked(blockedData):
                blocked = blockedData.blocked
            case let .blockedSlice(blockedSliceData):
                blocked = blockedSliceData.blocked
                hasMore = offset + Int32(blocked.count) < blockedSliceData.count
            }
            let peerIds = blocked.map { item -> PeerId in
                switch item {
                case let .peerBlocked(peerBlockedData):
                    return peerBlockedData.peerId.peerId
                }
            }
            VeilgramBlockedPeers.update(accountPeerId: accountPeerId, peerIds: peerIds, isBlocked: true)
            if hasMore && !blocked.isEmpty {
                return VeilgramBlockedPeers.loadPage(account: account, offset: offset + Int32(blocked.count))
            }
            return .complete()
        }
    }
}
