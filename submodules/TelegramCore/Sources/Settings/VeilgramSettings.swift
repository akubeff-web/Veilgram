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

        public var defaultValue: Bool {
            switch self {
            case .autoArchiveGroups, .alwaysOnline, .confirmSend, .keywordFilter, .hideStories, .unlockProtected, .keepViewOnce, .hidePhone, .streamerMode, .autoReply, .autoReplyContacts, .hidePremiumBadges, .hidePremiumBanners, .hidePremiumOffers, .hideGifts, .fastTransfers, .preloadMedia, .preloadMediaGroups, .hideUsername:
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

    /// Always Online wins over hiding the online status.
    public static var ghostOnline: Bool {
        return value(.ghost) && value(.ghostOnline) && !value(.alwaysOnline)
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

    public static func ghostRead(for peerId: PeerId) -> Bool {
        return ghostRead && !isGhostException(peerId)
    }

    public static func ghostTyping(for peerId: PeerId) -> Bool {
        return ghostTyping && !isGhostException(peerId)
    }

    public static func ghostStories(for peerId: PeerId) -> Bool {
        return ghostStories && !isGhostException(peerId)
    }

    public static var ghostTyping: Bool {
        return value(.ghost) && value(.ghostTyping)
    }

    public static var ghostRead: Bool {
        return value(.ghost) && value(.ghostRead)
    }

    public static var ghostStories: Bool {
        return value(.ghost) && value(.ghostStories)
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
