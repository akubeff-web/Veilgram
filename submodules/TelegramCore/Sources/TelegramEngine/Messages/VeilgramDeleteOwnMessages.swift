import Foundation
import Postbox
import SwiftSignalKit
internal import TelegramApi
import MtProtoKit

/// Veilgram: deletes every message the account sent in a chat, for everyone where the chat allows
/// it. Found by the server's search by sender, 100 at a time; emits the running count of deleted
/// messages and completes when the search finds no more.
public func veilgramDeleteAllOwnMessages(account: Account, peerId: PeerId) -> Signal<Int, NoError> {
    let network = account.network
    let postbox = account.postbox
    let stateManager = account.stateManager!
    return postbox.transaction { transaction -> (Peer?, Api.InputPeer?, Api.InputPeer?) in
        let peer = transaction.getPeer(peerId)
        return (peer, peer.flatMap(apiInputPeer), transaction.getPeer(account.peerId).flatMap(apiInputPeer))
    }
    |> mapToSignal { peer, inputPeer, accountInputPeer -> Signal<Int, NoError> in
        guard let peer, let inputPeer, let accountInputPeer else {
            return .single(0)
        }
        func step(deleted: Int, seen: Set<MessageId>) -> Signal<Int, NoError> {
            return network.request(Api.functions.messages.search(flags: 1 << 0, peer: inputPeer, q: "", fromId: accountInputPeer, savedPeerId: nil, savedReaction: nil, topMsgId: nil, filter: .inputMessagesFilterEmpty, minDate: 0, maxDate: 0, offsetId: 0, addOffset: 0, limit: 100, maxId: 0, minId: 0, hash: 0))
            |> map(Optional.init)
            |> `catch` { _ -> Signal<Api.messages.Messages?, NoError> in
                return .single(nil)
            }
            |> mapToSignal { result -> Signal<Int, NoError> in
                guard let result else {
                    return .single(deleted)
                }
                let apiMessages: [Api.Message]
                switch result {
                case let .channelMessages(channelMessagesData):
                    apiMessages = channelMessagesData.messages
                case let .messages(messagesData):
                    apiMessages = messagesData.messages
                case let .messagesSlice(messagesSliceData):
                    apiMessages = messagesSliceData.messages
                case .messagesNotModified:
                    apiMessages = []
                }
                // The search may still list messages it was just asked to delete: stop there.
                let ids = apiMessages.compactMap { $0.id() }.filter { $0.peerId == peerId && !seen.contains($0) }
                if ids.isEmpty {
                    return .single(deleted)
                }
                let remote: Signal<Void, NoError>
                if peerId.namespace == Namespaces.Peer.CloudChannel, let inputChannel = apiInputChannel(peer) {
                    remote = network.request(Api.functions.channels.deleteMessages(channel: inputChannel, id: ids.map { $0.id }))
                    |> map(Optional.init)
                    |> `catch` { _ -> Signal<Api.messages.AffectedMessages?, NoError> in
                        return .single(nil)
                    }
                    |> map { result -> Void in
                        if let result, case let .affectedMessages(affectedMessagesData) = result {
                            stateManager.addUpdateGroups([.updateChannelPts(channelId: peerId.id._internalGetInt64Value(), pts: affectedMessagesData.pts, ptsCount: affectedMessagesData.ptsCount)])
                        }
                    }
                } else {
                    remote = network.request(Api.functions.messages.deleteMessages(flags: 1 << 0, id: ids.map { $0.id }))
                    |> map(Optional.init)
                    |> `catch` { _ -> Signal<Api.messages.AffectedMessages?, NoError> in
                        return .single(nil)
                    }
                    |> map { result -> Void in
                        if let result, case let .affectedMessages(affectedMessagesData) = result {
                            stateManager.addUpdateGroups([.updatePts(pts: affectedMessagesData.pts, ptsCount: affectedMessagesData.ptsCount)])
                        }
                    }
                }
                let local = postbox.transaction { transaction -> Void in
                    _internal_deleteMessages(transaction: transaction, mediaBox: postbox.mediaBox, ids: ids)
                }
                let updatedDeleted = deleted + ids.count
                return remote
                |> then(local)
                |> map { _ -> Int in
                    return updatedDeleted
                }
                |> then(step(deleted: updatedDeleted, seen: seen.union(ids)))
            }
        }
        return step(deleted: 0, seen: Set())
    }
}
