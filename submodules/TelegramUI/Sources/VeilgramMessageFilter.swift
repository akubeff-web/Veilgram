import Foundation
import TelegramCore

/// Whether a message is left out of the chat history: messages from blocked peers in groups and
/// channels, and incoming messages containing a word of the message filter.
func veilgramHidesMessage(_ message: EngineRawMessage, accountPeerId: EnginePeer.Id, keywords: [String]) -> Bool {
    guard message.flags.contains(.Incoming), message.id.namespace == Namespaces.Message.Cloud else {
        return false
    }
    if VeilgramSettings.hideBlocked, message.id.peerId.namespace != Namespaces.Peer.CloudUser, let authorId = message.author?.id, VeilgramBlockedPeers.contains(accountPeerId: accountPeerId, peerId: authorId) {
        return true
    }
    if !keywords.isEmpty, !message.text.isEmpty {
        let text = message.text.lowercased()
        for keyword in keywords {
            if text.contains(keyword) {
                return true
            }
        }
    }
    return false
}
