import Foundation
import Postbox
import SwiftSignalKit

/// Veilgram's auto-reply: one message, sent once, to each private chat a user starts.
///
/// The chats are decided in the replay like the auto-archive ones (before its operations apply,
/// while the chat still has no messages), remembered as answered at once so a reply is never sent
/// twice, and handed to the account, which sends the reply in a transaction of its own.
private enum VeilgramAutoReplyQueue {
    static let pending = ValuePipe<(accountPeerId: PeerId, peerId: PeerId)>()
}

private func veilgramAutoRepliedKey(_ accountPeerId: PeerId) -> String {
    return "veilgram.autoReplied.\(accountPeerId.toInt64())"
}

func veilgramAutoReplyCandidates(transaction: Transaction, accountPeerId: PeerId, operations: [AccountStateMutationOperation], addedIncomingMessageIds: [MessageId]) -> Set<PeerId> {
    if !VeilgramSettings.autoReply || VeilgramSettings.autoReplyText.isEmpty || addedIncomingMessageIds.isEmpty {
        return Set()
    }
    let includeContacts = VeilgramSettings.autoReplyContacts
    let servicePeerId = PeerId(namespace: Namespaces.Peer.CloudUser, id: PeerId.Id._internalFromInt64Value(777000))
    let replied = Set((UserDefaults.standard.array(forKey: veilgramAutoRepliedKey(accountPeerId)) as? [Int64]) ?? [])

    var peersWithOutgoingMessages = Set<PeerId>()
    for operation in operations {
        if case let .AddMessages(messages, _) = operation {
            for message in messages where !message.flags.contains(.Incoming) {
                peersWithOutgoingMessages.insert(message.id.peerId)
            }
        }
    }

    var result = Set<PeerId>()
    for id in addedIncomingMessageIds {
        let peerId = id.peerId
        if result.contains(peerId) || id.namespace != Namespaces.Message.Cloud || peerId.namespace != Namespaces.Peer.CloudUser {
            continue
        }
        if peerId == accountPeerId || peerId == servicePeerId || peersWithOutgoingMessages.contains(peerId) || replied.contains(peerId.toInt64()) {
            continue
        }
        if let user = transaction.getPeer(peerId) as? TelegramUser, user.botInfo != nil || user.flags.contains(.isSupport) {
            continue
        }
        if !includeContacts && transaction.isPeerContact(peerId: peerId) {
            continue
        }
        if transaction.getTopPeerMessageIndex(peerId: peerId) != nil {
            continue
        }
        result.insert(peerId)
    }
    return result
}

func veilgramScheduleAutoReplies(accountPeerId: PeerId, peerIds: Set<PeerId>) {
    if peerIds.isEmpty {
        return
    }
    let key = veilgramAutoRepliedKey(accountPeerId)
    var replied = (UserDefaults.standard.array(forKey: key) as? [Int64]) ?? []
    replied.append(contentsOf: peerIds.map { $0.toInt64() })
    UserDefaults.standard.set(replied, forKey: key)
    for peerId in peerIds {
        VeilgramAutoReplyQueue.pending.putNext((accountPeerId, peerId))
    }
}

func managedVeilgramAutoReply(account: Account) -> Signal<Never, NoError> {
    let accountPeerId = account.peerId
    return VeilgramAutoReplyQueue.pending.signal()
    |> filter { item in
        return item.accountPeerId == accountPeerId
    }
    |> mapToQueue { [weak account] item -> Signal<Never, NoError> in
        let text = VeilgramSettings.autoReplyText
        guard let account, !text.isEmpty else {
            return .complete()
        }
        return enqueueMessages(account: account, peerId: item.peerId, messages: [.message(text: text, attributes: [], inlineStickers: [:], mediaReference: nil, threadId: nil, replyToMessageId: nil, replyToStoryId: nil, localGroupingKey: nil, correlationId: nil, bubbleUpEmojiOrStickersets: [])])
        |> ignoreValues
    }
}
