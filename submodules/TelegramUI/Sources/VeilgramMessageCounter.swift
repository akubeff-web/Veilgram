import Foundation
import SwiftSignalKit
import TelegramCore
import AccountContext
import LocalizedPeerData
import TelegramPresentationData
import OverlayStatusController
import PresentationDataUtils
import SettingsUI
import UndoUI

/// How many messages each participant of a chat sent, most first. Counted by the server one
/// participant at a time: both sides of a private chat, the members of a basic group, or the 100
/// most recently active members of a supergroup. A broadcast channel has no per-author counts.
func veilgramMessageCounts(context: AccountContext, peer: EnginePeer) -> Signal<[(peer: EnginePeer, count: Int)], NoError> {
    let participants: Signal<[EnginePeer], NoError>
    switch peer {
    case .user:
        participants = context.engine.data.get(TelegramEngine.EngineData.Item.Peer.Peer(id: context.account.peerId))
        |> map { accountPeer -> [EnginePeer] in
            var result: [EnginePeer] = []
            if let accountPeer {
                result.append(accountPeer)
            }
            if peer.id != context.account.peerId {
                result.append(peer)
            }
            return result
        }
    case .legacyGroup:
        participants = context.engine.data.get(TelegramEngine.EngineData.Item.Peer.LegacyGroupParticipants(id: peer.id))
        |> mapToSignal { participants -> Signal<[EnginePeer], NoError> in
            let ids = participants.knownValue?.map(\.peerId) ?? []
            return context.engine.data.get(EngineDataList(ids.map(TelegramEngine.EngineData.Item.Peer.Peer.init(id:))))
            |> map { peers -> [EnginePeer] in
                return peers.compactMap { $0 }
            }
        }
    case let .channel(channel):
        if case .broadcast = channel.info {
            participants = .single([])
        } else {
            participants = context.engine.peers.channelMembers(peerId: peer.id, category: .recent(.all), offset: 0, limit: 100)
            |> map { members -> [EnginePeer] in
                return members?.map(\.peer) ?? []
            }
        }
    default:
        participants = .single([])
    }

    if case .user = peer, peer.id != context.account.peerId {
        // A private chat: the server answers a search by the other side's id unreliably, so their
        // count is the chat's total less the account's own.
        let total = context.engine.messages.getSearchMessageCount(location: .peer(peerId: peer.id, fromId: nil, tags: nil, reactions: nil, threadId: nil, minDate: nil, maxDate: nil), query: "")
        let own = context.engine.messages.getSearchMessageCount(location: .peer(peerId: peer.id, fromId: context.account.peerId, tags: nil, reactions: nil, threadId: nil, minDate: nil, maxDate: nil), query: "")
        return combineLatest(participants, total, own)
        |> map { peers, total, own -> [(peer: EnginePeer, count: Int)] in
            var result: [(peer: EnginePeer, count: Int)] = []
            let ownCount = own ?? 0
            let otherCount = max(0, (total ?? 0) - ownCount)
            for participant in peers {
                let count = participant.id == context.account.peerId ? ownCount : otherCount
                if count > 0 {
                    result.append((participant, count))
                }
            }
            return result.sorted(by: { $0.count > $1.count })
        }
    }

    return participants
    |> mapToSignal { peers -> Signal<[(peer: EnginePeer, count: Int)], NoError> in
        // One request after another: a burst of searches gets flood-limited.
        func count(from index: Int, result: [(peer: EnginePeer, count: Int)]) -> Signal<[(peer: EnginePeer, count: Int)], NoError> {
            if index >= peers.count {
                return .single(result.sorted(by: { $0.count > $1.count }))
            }
            let participant = peers[index]
            return context.engine.messages.getSearchMessageCount(location: .peer(peerId: peer.id, fromId: participant.id, tags: nil, reactions: nil, threadId: nil, minDate: nil, maxDate: nil), query: "")
            |> mapToSignal { value -> Signal<[(peer: EnginePeer, count: Int)], NoError> in
                var result = result
                if let value, value > 0 {
                    result.append((participant, value))
                }
                return count(from: index + 1, result: result)
            }
        }
        return count(from: 0, result: [])
    }
}

extension ChatControllerImpl {
    func veilgramOpenMessageCounter(peer: EnginePeer) {
        let presentationData = self.presentationData
        let strings = presentationData.strings
        let disposable = MetaDisposable()
        let progress = OverlayStatusController(theme: presentationData.theme, type: .loading(cancelled: {
            disposable.dispose()
        }))
        self.present(progress, in: .window(.root))
        disposable.set((veilgramMessageCounts(context: self.context, peer: peer)
        |> deliverOnMainQueue).start(next: { [weak self, weak progress] counts in
            progress?.dismiss()
            guard let self else {
                return
            }
            var rows: [(label: String, value: String)] = counts.map { item in
                return (item.peer.compactDisplayTitle, "\(item.count)")
            }
            if rows.isEmpty {
                rows.append(("", veilgramLocalized(strings, "Veilgram.MessageCounterEmpty", strings.Veilgram_MessageCounterEmpty)))
            }
            self.push(veilgramRowsController(context: self.context, title: veilgramLocalized(strings, "Veilgram.MessageCounter", strings.Veilgram_MessageCounter), rows: rows))
        }))
    }
}

extension ChatControllerImpl {
    func veilgramDeleteAllOwnMessages(peerId: EnginePeer.Id) {
        let presentationData = self.presentationData
        let strings = presentationData.strings
        self.present(textAlertController(context: self.context, updatedPresentationData: self.updatedPresentationData, title: veilgramLocalized(strings, "Veilgram.DeleteMyMessages", strings.Veilgram_DeleteMyMessages), text: veilgramLocalized(strings, "Veilgram.DeleteMyMessagesConfirm", strings.Veilgram_DeleteMyMessagesConfirm), actions: [TextAlertAction(type: .genericAction, title: strings.Common_Cancel, action: {}), TextAlertAction(type: .destructiveAction, title: strings.Common_Delete, action: { [weak self] in
            guard let self else {
                return
            }
            let disposable = MetaDisposable()
            let progress = OverlayStatusController(theme: presentationData.theme, type: .loading(cancelled: {
                disposable.dispose()
            }))
            self.present(progress, in: .window(.root))
            var deletedCount = 0
            disposable.set((veilgramDeleteAllOwnMessages(account: self.context.account, peerId: peerId)
            |> deliverOnMainQueue).start(next: { count in
                deletedCount = count
            }, completed: { [weak self, weak progress] in
                progress?.dismiss()
                guard let self else {
                    return
                }
                let text = veilgramLocalized(strings, "Veilgram.DeleteMyMessagesDone", strings.Veilgram_DeleteMyMessagesDone).replacingOccurrences(of: "{count}", with: "\(deletedCount)")
                self.present(UndoOverlayController(presentationData: presentationData, content: .succeed(text: text, timeout: nil, customUndoText: nil), elevatedLayout: false, action: { _ in
                    return false
                }), in: .current)
            }))
        })]), in: .window(.root))
    }
}
