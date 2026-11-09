import Foundation
import SwiftSignalKit
import Postbox

/// Veilgram feature switches. Values are kept in `UserDefaults.standard` and read at the moment a
/// feature does its work, so a change applies immediately. A sub-option only takes effect while its
/// main switch is on: read the effective values (`ghostOnline`, `keepDeleted`, ...), not `value(_:)`.
/// The Calls tab has no key here: it stays on the existing `CallListSettings.showTab`.
public enum VeilgramSettings {
    public enum Key: String, CaseIterable {
        case ghost
        case ghostOnline
        case ghostTyping
        case ghostRead
        case ghostStories
        case alwaysOnline
        case keepDeleted
        case deletedIcon
        case editHistory
        case autoArchive
        case autoArchiveGroups
        case tabContacts
        case tabNews
        case loginOpenTelegramButton
        case confirmSend
        case hideBlocked
        case keywordFilter
        case hideStories
        case unlockProtected
        case keepViewOnce
        case hidePhone
        case streamerMode
        case autoReply
        case autoReplyContacts
        case hidePremiumBadges
        case hidePremiumBanners
        case hidePremiumOffers
        case hideGifts
        case fastTransfers
        case preloadMedia
        case preloadMediaGroups
        case localTranscription
        case hideUsername
        case localTranslation
        case hideChatListTime
        case hideChatListPreviews
        case confirmLinks
        case quietHours
        case hideSponsored
        case readOnReply
        case ghostOfflineSend
        case keepKickedChats
        case localNotifications

        public var defaultValue: Bool {
            switch self {
            case .autoArchiveGroups, .alwaysOnline, .confirmSend, .keywordFilter, .hideStories, .unlockProtected, .keepViewOnce, .hidePhone, .streamerMode, .autoReply, .autoReplyContacts, .hidePremiumBadges, .hidePremiumBanners, .hidePremiumOffers, .hideGifts, .fastTransfers, .preloadMedia, .preloadMediaGroups, .hideUsername, .hideChatListTime, .hideChatListPreviews, .confirmLinks, .quietHours, .ghostOfflineSend:
                return false
            default:
                return true
            }
        }
    }

    private static let keyPrefix = "veilgram."
    private static let version = ValuePromise<Int>(0, ignoreRepeated: false)
    private static let versionLock = NSLock()
    private static var currentVersion: Int = 0

    /// The stored value of a switch, ignoring its main switch.
    public static func value(_ key: Key) -> Bool {
        if let value = UserDefaults.standard.object(forKey: keyPrefix + key.rawValue) as? Bool {
            return value
        }
        return key.defaultValue
    }

    public static func set(_ key: Key, _ value: Bool) {
        UserDefaults.standard.set(value, forKey: keyPrefix + key.rawValue)
        self.notifyChanged()
    }

    private static func notifyChanged() {
        versionLock.lock()
        currentVersion += 1
        let updatedVersion = currentVersion
        versionLock.unlock()
        version.set(updatedVersion)
    }

    /// Emits immediately and after every change of any switch.
    public static var updated: Signal<Void, NoError> {
        return version.get() |> map { _ -> Void in
            return Void()
        }
    }

    private static let ghostDisabledAccountsKey = keyPrefix + "ghostDisabledAccounts"
    private static let ghostDisabledAccountsCache = Atomic<Set<Int64>?>(value: nil)

    /// Accounts where ghost mode is off although its main switch is on.
    public static var ghostDisabledAccounts: Set<Int64> {
        if let cached = ghostDisabledAccountsCache.with({ $0 }) {
            return cached
        }
        let value = Set((UserDefaults.standard.array(forKey: ghostDisabledAccountsKey) as? [Int64]) ?? [])
        let _ = ghostDisabledAccountsCache.swap(value)
        return value
    }

    public static func setGhostEnabled(_ isEnabled: Bool, account: PeerId) {
        var value = ghostDisabledAccounts
        if isEnabled {
            value.remove(account.toInt64())
        } else {
            value.insert(account.toInt64())
        }
        UserDefaults.standard.set(Array(value), forKey: ghostDisabledAccountsKey)
        let _ = ghostDisabledAccountsCache.swap(value)
        self.notifyChanged()
    }

    /// The main switch for one account. A nil account (no account known yet) follows the main switch.
    public static func ghostEnabled(account: PeerId?) -> Bool {
        guard value(.ghost) else {
            return false
        }
        if let account, ghostDisabledAccounts.contains(account.toInt64()) {
            return false
        }
        return true
    }

    /// Always Online wins over hiding the online status.
    public static func ghostOnline(account: PeerId?) -> Bool {
        return ghostEnabled(account: account) && value(.ghostOnline) && !value(.alwaysOnline)
    }

    public static var alwaysOnline: Bool {
        return value(.alwaysOnline)
    }

    private static let ghostExceptionsKey = keyPrefix + "ghostExceptions"
    private static let ghostExceptionsCache = Atomic<Set<Int64>?>(value: nil)

    /// Chats where ghost mode is off: read receipts, typing and story views go out as usual there.
    /// The online status belongs to the whole account and cannot differ per chat.
    public static var ghostExceptions: Set<Int64> {
        if let cached = ghostExceptionsCache.with({ $0 }) {
            return cached
        }
        let value = Set((UserDefaults.standard.array(forKey: ghostExceptionsKey) as? [Int64]) ?? [])
        let _ = ghostExceptionsCache.swap(value)
        return value
    }

    public static func isGhostException(_ peerId: PeerId) -> Bool {
        return ghostExceptions.contains(peerId.toInt64())
    }

    public static func setGhostException(_ peerId: PeerId, _ isException: Bool) {
        var value = ghostExceptions
        if isException {
            value.insert(peerId.toInt64())
        } else {
            value.remove(peerId.toInt64())
        }
        UserDefaults.standard.set(Array(value), forKey: ghostExceptionsKey)
        let _ = ghostExceptionsCache.swap(value)
        self.notifyChanged()
    }

    private static let hiddenChatsKey = keyPrefix + "hiddenChats"
    private static let hiddenChatsCache = Atomic<Set<Int64>?>(value: nil)
    private static let hiddenChatsRevealedValue = Atomic<Bool>(value: false)

    public struct HiddenChatsState: Equatable {
        public let hidden: Set<Int64>
        public let isRevealed: Bool
    }

    /// Chats left out of the chat list until revealed (for this launch) from the Chats tab menu.
    public static var hiddenChats: Set<Int64> {
        if let cached = hiddenChatsCache.with({ $0 }) {
            return cached
        }
        let value = Set((UserDefaults.standard.array(forKey: hiddenChatsKey) as? [Int64]) ?? [])
        let _ = hiddenChatsCache.swap(value)
        return value
    }

    public static var hiddenChatsState: HiddenChatsState {
        return HiddenChatsState(hidden: hiddenChats, isRevealed: hiddenChatsRevealed)
    }

    public static var hiddenChatsRevealed: Bool {
        return hiddenChatsRevealedValue.with { $0 }
    }

    public static func setHiddenChatsRevealed(_ value: Bool) {
        let _ = hiddenChatsRevealedValue.swap(value)
        self.notifyChanged()
    }

    public static func isChatHidden(_ peerId: PeerId) -> Bool {
        return !hiddenChatsRevealed && hiddenChats.contains(peerId.toInt64())
    }

    public static func isChatInHiddenList(_ peerId: PeerId) -> Bool {
        return hiddenChats.contains(peerId.toInt64())
    }

    public static func setChatHidden(_ peerId: PeerId, _ isHidden: Bool) {
        var value = hiddenChats
        if isHidden {
            value.insert(peerId.toInt64())
        } else {
            value.remove(peerId.toInt64())
        }
        UserDefaults.standard.set(Array(value), forKey: hiddenChatsKey)
        let _ = hiddenChatsCache.swap(value)
        self.notifyChanged()
    }

    public static func ghostRead(for peerId: PeerId, account: PeerId?) -> Bool {
        return ghostRead(account: account) && !isGhostException(peerId)
    }

    public static func ghostTyping(for peerId: PeerId, account: PeerId?) -> Bool {
        return ghostEnabled(account: account) && value(.ghostTyping) && !isGhostException(peerId)
    }

    public static func ghostStories(for peerId: PeerId, account: PeerId?) -> Bool {
        return ghostEnabled(account: account) && value(.ghostStories) && !isGhostException(peerId)
    }

    /// Sending a message reads the chat, which ghost mode would otherwise leave unread for the sender.
    public static func readOnReply(for peerId: PeerId, account: PeerId?) -> Bool {
        return ghostRead(for: peerId, account: account) && value(.readOnReply)
    }

    /// Messages go out as scheduled ones a few seconds ahead, which the server does not show as the
    /// sender going online (AyuGram's "use scheduled messages").
    public static func ghostOfflineSend(account: PeerId?) -> Bool {
        return ghostOnline(account: account) && value(.ghostOfflineSend)
    }

    public static func ghostRead(account: PeerId?) -> Bool {
        return ghostEnabled(account: account) && value(.ghostRead)
    }

    public static var keepDeleted: Bool {
        return value(.keepDeleted)
    }

    public static var editHistory: Bool {
        return value(.editHistory)
    }

    public static var deletedIcon: Bool {
        return value(.keepDeleted) && value(.deletedIcon)
    }

    public static var autoArchive: Bool {
        return value(.autoArchive)
    }

    public static var autoArchiveGroups: Bool {
        return value(.autoArchive) && value(.autoArchiveGroups)
    }

    public static var tabContacts: Bool {
        return value(.tabContacts)
    }

    public static var tabNews: Bool {
        return value(.tabNews)
    }

    public static var unlockProtected: Bool {
        return value(.unlockProtected)
    }

    public static var keepViewOnce: Bool {
        return value(.keepViewOnce)
    }

    public enum ProfileBannerKind: String {
        case color
        case photo
        case video
    }

    private static let profileBannerKindKey = keyPrefix + "profileBanner.kind"
    private static let profileBannerColorKey = keyPrefix + "profileBanner.color"

    /// The header of the own profile, drawn by Veilgram on this device only.
    public static var profileBannerKind: ProfileBannerKind? {
        guard let value = UserDefaults.standard.string(forKey: profileBannerKindKey) else {
            return nil
        }
        return ProfileBannerKind(rawValue: value)
    }

    public static var profileBannerColor: UInt32 {
        return UInt32(truncatingIfNeeded: UserDefaults.standard.integer(forKey: profileBannerColorKey))
    }

    /// Where the banner's photo or video is kept: the app's Documents folder.
    public static func profileBannerFileURL(kind: ProfileBannerKind) -> URL? {
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        switch kind {
        case .color:
            return nil
        case .photo:
            return documents.appendingPathComponent("veilgram-banner.jpg")
        case .video:
            return documents.appendingPathComponent("veilgram-banner.mp4")
        }
    }

    public static func setProfileBanner(kind: ProfileBannerKind?, color: UInt32 = 0) {
        if let kind {
            UserDefaults.standard.set(kind.rawValue, forKey: profileBannerKindKey)
        } else {
            UserDefaults.standard.removeObject(forKey: profileBannerKindKey)
        }
        UserDefaults.standard.set(Int(color), forKey: profileBannerColorKey)
        self.notifyChanged()
    }

    public static var localNotifications: Bool {
        return value(.localNotifications)
    }

    public static var keepKickedChats: Bool {
        return value(.keepKickedChats)
    }

    public static var hideSponsored: Bool {
        return value(.hideSponsored)
    }

    public static var quietHours: Bool {
        return value(.quietHours)
    }

    public static var confirmLinks: Bool {
        return value(.confirmLinks)
    }

    public static var hideChatListTime: Bool {
        return value(.hideChatListTime)
    }

    public static var hideChatListPreviews: Bool {
        return value(.hideChatListPreviews)
    }

    public static var localTranslation: Bool {
        return value(.localTranslation)
    }

    public static var hideUsername: Bool {
        return value(.hideUsername)
    }

    public static var localTranscription: Bool {
        return value(.localTranscription)
    }

    public static var preloadMedia: Bool {
        return value(.preloadMedia)
    }

    public static var preloadMediaGroups: Bool {
        return value(.preloadMedia) && value(.preloadMediaGroups)
    }

    public static var fastTransfers: Bool {
        return value(.fastTransfers)
    }

    public static var hidePremiumBadges: Bool {
        return value(.hidePremiumBadges)
    }

    public static var hidePremiumBanners: Bool {
        return value(.hidePremiumBanners)
    }

    public static var hidePremiumOffers: Bool {
        return value(.hidePremiumOffers)
    }

    public static var hideGifts: Bool {
        return value(.hideGifts)
    }

    public static var autoReply: Bool {
        return value(.autoReply)
    }

    public static var autoReplyContacts: Bool {
        return value(.autoReply) && value(.autoReplyContacts)
    }

    private static let autoReplyTextKey = keyPrefix + "autoReplyText"

    /// The auto-reply as typed, trimmed.
    public static var autoReplyText: String {
        return (UserDefaults.standard.string(forKey: autoReplyTextKey) ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public static var autoReplyRawText: String {
        return UserDefaults.standard.string(forKey: autoReplyTextKey) ?? ""
    }

    public static func setAutoReplyText(_ text: String) {
        UserDefaults.standard.set(text, forKey: autoReplyTextKey)
        self.notifyChanged()
    }

    public static var streamerMode: Bool {
        return value(.streamerMode)
    }

    public static var hidePhone: Bool {
        return value(.hidePhone)
    }

    public static var hideStories: Bool {
        return value(.hideStories)
    }

    public static var hideBlocked: Bool {
        return value(.hideBlocked)
    }

    private static let filterKeywordsKey = keyPrefix + "filterKeywords"
    private static let filterKeywordsCache = Atomic<[String]?>(value: nil)

    /// The words of the message filter as typed: one per line or separated by commas.
    public static var filterKeywordsText: String {
        return UserDefaults.standard.string(forKey: filterKeywordsKey) ?? ""
    }

    private static let deletedMarkKey = keyPrefix + "deletedMark"
    private static let editedMarkKey = keyPrefix + "editedMark"

    /// Text shown before the time of a message deleted on the server, in place of the trash icon.
    /// Empty: the icon.
    public static var deletedMarkText: String {
        return UserDefaults.standard.string(forKey: deletedMarkKey) ?? ""
    }

    public static func setDeletedMarkText(_ text: String) {
        UserDefaults.standard.set(text, forKey: deletedMarkKey)
        self.notifyChanged()
    }

    /// Text shown before the time of an edited message in place of "edited". Empty: Telegram's label.
    public static var editedMarkText: String {
        return UserDefaults.standard.string(forKey: editedMarkKey) ?? ""
    }

    public static func setEditedMarkText(_ text: String) {
        UserDefaults.standard.set(text, forKey: editedMarkKey)
        self.notifyChanged()
    }

    public static func setFilterKeywordsText(_ text: String) {
        UserDefaults.standard.set(text, forKey: filterKeywordsKey)
        let _ = filterKeywordsCache.swap(nil)
        self.notifyChanged()
    }

    /// The words of the message filter, lowercased; empty while the filter is off.
    public static var filterKeywords: [String] {
        if !value(.keywordFilter) {
            return []
        }
        if let cached = filterKeywordsCache.with({ $0 }) {
            return cached
        }
        let words = filterKeywordsText
            .components(separatedBy: CharacterSet(charactersIn: ",\n"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { !$0.isEmpty }
        let _ = filterKeywordsCache.swap(words)
        return words
    }

    public static var confirmSend: Bool {
        return value(.confirmSend)
    }

    public static var loginOpenTelegramButton: Bool {
        return value(.loginOpenTelegramButton)
    }
}
