import Foundation
import Postbox
import SwiftSignalKit

/// Veilgram: downloads the media of incoming messages as they arrive, so a photo, video or file
/// deleted before it was opened can still be viewed (the server no longer serves it then).
/// Private chats always, groups when chosen; channels never; files over 20 MB are left alone.
private enum VeilgramPreloadQueue {
    static let pending = ValuePipe<(accountPeerId: PeerId, messageIds: [MessageId])>()
}

private let veilgramPreloadMaxFileSize: Int64 = 20 * 1024 * 1024

func veilgramSchedulePreload(accountPeerId: PeerId, addedIncomingMessageIds: [MessageId]) {
    if !VeilgramSettings.preloadMedia || addedIncomingMessageIds.isEmpty {
        return
    }
    let ids = addedIncomingMessageIds.filter { $0.namespace == Namespaces.Message.Cloud }
    if !ids.isEmpty {
        VeilgramPreloadQueue.pending.putNext((accountPeerId, ids))
    }
}

func managedVeilgramPreloadMedia(account: Account) -> Disposable {
    let accountPeerId = account.peerId
    let postbox = account.postbox
    let fetches = DisposableSet()
    let disposable = (VeilgramPreloadQueue.pending.signal()
    |> filter { item in
        return item.accountPeerId == accountPeerId
    }
    |> mapToSignal { item -> Signal<[(MediaResourceReference, MediaResourceUserContentType, PeerId)], NoError> in
        let includeGroups = VeilgramSettings.preloadMediaGroups
        return postbox.transaction { transaction -> [(MediaResourceReference, MediaResourceUserContentType, PeerId)] in
            var result: [(MediaResourceReference, MediaResourceUserContentType, PeerId)] = []
            for id in item.messageIds {
                switch id.peerId.namespace {
                case Namespaces.Peer.CloudUser:
                    break
                case Namespaces.Peer.CloudGroup:
                    if !includeGroups {
                        continue
                    }
                case Namespaces.Peer.CloudChannel:
                    guard includeGroups, let channel = transaction.getPeer(id.peerId) as? TelegramChannel, case .group = channel.info else {
                        continue
                    }
                default:
                    continue
                }
                guard let message = transaction.getMessage(id) else {
                    continue
                }
                for media in message.media {
                    if let image = media as? TelegramMediaImage, let representation = largestImageRepresentation(image.representations) {
                        result.append((.media(media: .message(message: MessageReference(message), media: image), resource: representation.resource), .image, id.peerId))
                    } else if let file = media as? TelegramMediaFile, let size = file.size, size <= veilgramPreloadMaxFileSize {
                        let contentType: MediaResourceUserContentType
                        if file.isVideo {
                            contentType = .video
                        } else if file.isVoice || file.isMusic {
                            contentType = .audio
                        } else if file.isSticker || file.isAnimatedSticker {
                            continue
                        } else {
                            contentType = .file
                        }
                        result.append((.media(media: .message(message: MessageReference(message), media: file), resource: file.resource), contentType, id.peerId))
                    }
                }
            }
            return result
        }
    }
    |> deliverOnMainQueue).start(next: { items in
        for (reference, contentType, peerId) in items {
            fetches.add(fetchedMediaResource(mediaBox: postbox.mediaBox, userLocation: .peer(peerId), userContentType: contentType, reference: reference).start())
        }
    })
    return ActionDisposable {
        disposable.dispose()
        fetches.dispose()
    }
}
