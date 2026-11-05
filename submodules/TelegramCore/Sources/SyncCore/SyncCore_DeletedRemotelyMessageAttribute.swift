import Foundation
import Postbox

/// Marks a cloud message that the server deleted (by the other side or an admin) and Veilgram kept.
public class DeletedRemotelyMessageAttribute: MessageAttribute {
    public let date: Int32

    public init(date: Int32) {
        self.date = date
    }

    required public init(decoder: PostboxDecoder) {
        self.date = decoder.decodeInt32ForKey("d", orElse: 0)
    }

    public func encode(_ encoder: PostboxEncoder) {
        encoder.encodeInt32(self.date, forKey: "d")
    }
}

public extension Message {
    var isDeletedRemotely: Bool {
        for attribute in self.attributes {
            if attribute is DeletedRemotelyMessageAttribute {
                return true
            }
        }
        return false
    }
}

/// Called where a message is about to be deleted because the server no longer has it. Returns true
/// when Veilgram keeps the message instead (it is then marked with `DeletedRemotelyMessageAttribute`)
/// and the caller must not delete it. Only regular messages of cloud chats other than Saved Messages
/// are kept; secret chats, scheduled messages and quick replies use other namespaces.
func veilgramKeepRemotelyDeletedMessage(transaction: Transaction, accountPeerId: PeerId, id: MessageId) -> Bool {
    if !VeilgramSettings.keepDeleted {
        return false
    }
    if id.namespace != Namespaces.Message.Cloud || id.peerId == accountPeerId {
        return false
    }
    switch id.peerId.namespace {
    case Namespaces.Peer.CloudUser, Namespaces.Peer.CloudGroup, Namespaces.Peer.CloudChannel:
        break
    default:
        return false
    }
    guard let message = transaction.getMessage(id) else {
        return false
    }
    if message.isDeletedRemotely {
        return true
    }
    let timestamp = Int32(CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970)
    transaction.updateMessage(id, update: { currentMessage in
        var storeForwardInfo: StoreMessageForwardInfo?
        if let forwardInfo = currentMessage.forwardInfo {
            storeForwardInfo = StoreMessageForwardInfo(authorId: forwardInfo.author?.id, sourceId: forwardInfo.source?.id, sourceMessageId: forwardInfo.sourceMessageId, date: forwardInfo.date, authorSignature: forwardInfo.authorSignature, psaType: forwardInfo.psaType, flags: forwardInfo.flags)
        }
        var attributes = currentMessage.attributes
        attributes.append(DeletedRemotelyMessageAttribute(date: timestamp))
        return .update(StoreMessage(id: currentMessage.id, customStableId: nil, globallyUniqueId: currentMessage.globallyUniqueId, groupingKey: currentMessage.groupingKey, threadId: currentMessage.threadId, timestamp: currentMessage.timestamp, flags: StoreMessageFlags(currentMessage.flags), tags: currentMessage.tags, globalTags: currentMessage.globalTags, localTags: currentMessage.localTags, forwardInfo: storeForwardInfo, authorId: currentMessage.author?.id, text: currentMessage.text, attributes: attributes, media: currentMessage.media))
    })
    return true
}
