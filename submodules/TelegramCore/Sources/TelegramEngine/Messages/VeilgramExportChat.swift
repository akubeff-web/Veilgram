import Foundation
import Postbox
import SwiftSignalKit
internal import TelegramApi
import MtProtoKit

public struct VeilgramExportedMessage {
    public enum Media {
        case none
        case photo
        case video
        case videoMessage
        case voice
        case audio
        case sticker
        case file
        case other
    }

    public let date: Int32
    public let author: String
    public let text: String
    public let media: Media
}

/// Veilgram: the whole history of a chat from the server, 100 messages a request, oldest first at the
/// end. Emits the number of messages fetched so far with nil, then the messages once complete.
public func veilgramExportChat(account: Account, peerId: PeerId) -> Signal<(count: Int, messages: [VeilgramExportedMessage]?), NoError> {
    let network = account.network
    let accountPeerId = account.peerId
    return account.postbox.transaction { transaction -> (Api.InputPeer?, [PeerId: String]) in
        var names: [PeerId: String] = [:]
        for id in [peerId, accountPeerId] {
            if let peer = transaction.getPeer(id) {
                names[id] = veilgramExportName(peer)
            }
        }
        return (transaction.getPeer(peerId).flatMap(apiInputPeer), names)
    }
    |> mapToSignal { inputPeer, initialNames -> Signal<(count: Int, messages: [VeilgramExportedMessage]?), NoError> in
        guard let inputPeer else {
            return .single((0, []))
        }
        func step(offsetId: Int32, collected: [VeilgramExportedMessage], names: [PeerId: String]) -> Signal<(count: Int, messages: [VeilgramExportedMessage]?), NoError> {
            return network.request(Api.functions.messages.getHistory(peer: inputPeer, offsetId: offsetId, offsetDate: 0, addOffset: 0, limit: 100, maxId: 0, minId: 0, hash: 0))
            |> map(Optional.init)
            |> `catch` { _ -> Signal<Api.messages.Messages?, NoError> in
                return .single(nil)
            }
            |> mapToSignal { result -> Signal<(count: Int, messages: [VeilgramExportedMessage]?), NoError> in
                var apiMessages: [Api.Message] = []
                var apiChats: [Api.Chat] = []
                var apiUsers: [Api.User] = []
                if let result {
                    switch result {
                    case let .messages(messagesData):
                        apiMessages = messagesData.messages
                        apiChats = messagesData.chats
                        apiUsers = messagesData.users
                    case let .messagesSlice(messagesSliceData):
                        apiMessages = messagesSliceData.messages
                        apiChats = messagesSliceData.chats
                        apiUsers = messagesSliceData.users
                    case let .channelMessages(channelMessagesData):
                        apiMessages = channelMessagesData.messages
                        apiChats = channelMessagesData.chats
                        apiUsers = channelMessagesData.users
                    case .messagesNotModified:
                        break
                    }
                }
                var names = names
                for user in apiUsers {
                    let peer = TelegramUser(user: user)
                    names[peer.id] = veilgramExportName(peer)
                }
                for chat in apiChats {
                    if let peer = parseTelegramGroupOrChannel(chat: chat) {
                        names[peer.id] = veilgramExportName(peer)
                    }
                }
                var collected = collected
                var minId: Int32?
                for apiMessage in apiMessages {
                    guard let message = StoreMessage(apiMessage: apiMessage, accountPeerId: accountPeerId, peerIsForum: false), case let .Id(id) = message.id else {
                        continue
                    }
                    minId = min(minId ?? id.id, id.id)
                    let authorId = message.authorId ?? peerId
                    collected.append(VeilgramExportedMessage(date: message.timestamp, author: names[authorId] ?? "", text: message.text, media: veilgramExportMedia(message.media)))
                }
                guard let minId, minId > 1, collected.count < 200_000 else {
                    return .single((collected.count, Array(collected.reversed())))
                }
                return .single((collected.count, nil))
                |> then(step(offsetId: minId, collected: collected, names: names))
            }
        }
        return step(offsetId: 0, collected: [], names: initialNames)
    }
}

private func veilgramExportName(_ peer: Peer) -> String {
    if let user = peer as? TelegramUser {
        let name = [user.firstName, user.lastName].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " ")
        return name.isEmpty ? (user.phone ?? "") : name
    } else if let group = peer as? TelegramGroup {
        return group.title
    } else if let channel = peer as? TelegramChannel {
        return channel.title
    }
    return ""
}

private func veilgramExportMedia(_ media: [Media]) -> VeilgramExportedMessage.Media {
    for item in media {
        if item is TelegramMediaImage {
            return .photo
        } else if let file = item as? TelegramMediaFile {
            if file.isInstantVideo {
                return .videoMessage
            } else if file.isVideo {
                return .video
            } else if file.isVoice {
                return .voice
            } else if file.isMusic {
                return .audio
            } else if file.isSticker || file.isAnimatedSticker {
                return .sticker
            } else {
                return .file
            }
        } else if !(item is TelegramMediaWebpage) {
            return .other
        }
    }
    return .none
}
