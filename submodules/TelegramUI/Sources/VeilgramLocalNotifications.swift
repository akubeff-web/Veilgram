import Foundation
import UserNotifications
import TelegramCore
import TelegramPresentationData
import AccountContext
import LocalizedPeerData

/// Veilgram: without push (a free Apple ID cannot sign the push entitlement), a message that arrives
/// while the app still runs in the background is reported with a local notification. iOS suspends the
/// app soon after it leaves the screen, so this covers only the time it is still running. Tapping it
/// opens the chat through the same keys a push notification carries (AppDelegate).
func veilgramPostLocalNotification(context: AccountContext, messages: [EngineMessage], notify: Bool) {
    guard VeilgramSettings.localNotifications, notify, let message = messages.first else {
        return
    }
    let peerId = message.id.peerId
    if peerId == context.account.peerId || VeilgramSettings.isChatHidden(peerId) {
        return
    }
    if VeilgramSettings.quietHours {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= 23 || hour < 8 {
            return
        }
    }
    let isMuted = message.attributes.contains(where: { attribute in
        if let attribute = attribute as? NotificationInfoMessageAttribute {
            return attribute.flags.contains(.muted)
        } else {
            return false
        }
    })

    let strings = context.sharedContext.currentPresentationData.with { $0 }.strings
    let chatTitle = message.peers[peerId].flatMap { EnginePeer($0).displayTitle(strings: strings, displayOrder: .firstLast) } ?? ""
    var body = message.text
    if body.isEmpty {
        body = veilgramLocalized(strings, "Veilgram.Media", strings.Veilgram_Media)
    }
    if messages.count > 1 && message.text.isEmpty {
        body += " (\(messages.count))"
    }
    if peerId.namespace != Namespaces.Peer.CloudUser, let author = message.author, author.id != peerId {
        body = author.compactDisplayTitle + ": " + body
    }

    let content = UNMutableNotificationContent()
    if VeilgramSettings.streamerMode || VeilgramSettings.isChatLocked(peerId) {
        content.title = "Veilgram"
        content.body = veilgramLocalized(strings, "Veilgram.NewMessage", strings.Veilgram_NewMessage)
    } else {
        content.title = chatTitle
        content.body = body
    }
    if !isMuted {
        content.sound = .default
    }
    content.threadIdentifier = "\(peerId.toInt64())"
    content.userInfo = [
        "accountId": context.account.id.int64,
        "peerId": peerId.toInt64(),
        "messageId.namespace": message.id.namespace,
        "messageId.id": message.id.id
    ]

    let center = UNUserNotificationCenter.current()
    center.getNotificationSettings(completionHandler: { settings in
        let post = {
            let request = UNNotificationRequest(identifier: "veilgram_\(peerId.toInt64())_\(message.id.id)", content: content, trigger: nil)
            center.add(request, withCompletionHandler: nil)
        }
        switch settings.authorizationStatus {
        case .notDetermined:
            center.requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { granted, _ in
                if granted {
                    post()
                }
            })
        case .denied:
            break
        default:
            post()
        }
    })
}
