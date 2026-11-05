import Foundation
import Postbox

/// Veilgram's client-side "archive and mute new chats" (the server setting needs Premium).
///
/// Decided before the replay applies its operations, while the chat still has no messages: the chats
/// that an incoming message of this batch starts. A chat is new when it is not Saved Messages or the
/// service account, has no stored messages and no chat list entry yet, and the batch carries no
/// outgoing message to it. Private chats count only when the user is not a contact; groups and
/// channels only with `autoArchiveGroups`.
func veilgramAutoArchiveCandidates(transaction: Transaction, accountPeerId: PeerId, operations: [AccountStateMutationOperation], addedIncomingMessageIds: [MessageId]) -> Set<PeerId> {
    if !VeilgramSettings.autoArchive || addedIncomingMessageIds.isEmpty {
        return Set()
    }
    let includeGroups = VeilgramSettings.autoArchiveGroups
    let servicePeerId = PeerId(namespace: Namespaces.Peer.CloudUser, id: PeerId.Id._internalFromInt64Value(777000))

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
        if result.contains(peerId) || id.namespace != Namespaces.Message.Cloud {
            continue
        }
        if peerId == accountPeerId || peerId == servicePeerId || peersWithOutgoingMessages.contains(peerId) {
            continue
        }
        switch peerId.namespace {
        case Namespaces.Peer.CloudUser:
            if transaction.isPeerContact(peerId: peerId) {
                continue
            }
        case Namespaces.Peer.CloudGroup, Namespaces.Peer.CloudChannel:
            if !includeGroups {
                continue
            }
        default:
            continue
        }
        if transaction.getTopPeerMessageIndex(peerId: peerId) != nil {
            continue
        }
        if case .ifHasMessagesOrOneOf = transaction.getPeerChatListInclusion(peerId) {
            continue
        }
        result.insert(peerId)
    }
    return result
}

/// Applied after the replay's operations, in the same transaction and before notifications are built,
/// so the chat list entry and notification settings fetched for the new chat do not undo it. Uses the
/// same synchronized paths as the manual Archive and Mute actions.
func veilgramApplyAutoArchive(transaction: Transaction, peerIds: Set<PeerId>) {
    for peerId in peerIds {
        if case .notIncluded = transaction.getPeerChatListInclusion(peerId) {
            transaction.updatePeerChatListInclusion(peerId, inclusion: .ifHasMessagesOrOneOf(groupId: .root, pinningIndex: nil, minTimestamp: nil))
        }
        _internal_updatePeerGroupIdInteractively(transaction: transaction, peerId: peerId, groupId: Namespaces.PeerGroup.archive)

        let previousSettings = (transaction.getPeerNotificationSettings(id: peerId) as? TelegramPeerNotificationSettings) ?? TelegramPeerNotificationSettings.defaultSettings
        transaction.updatePendingPeerNotificationSettings(peerId: peerId, settings: previousSettings.withUpdatedMuteState(.muted(until: Int32.max)))
    }
}
