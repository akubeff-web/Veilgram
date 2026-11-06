import Foundation
import SwiftSignalKit

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

        public var defaultValue: Bool {
            switch self {
            case .autoArchiveGroups, .alwaysOnline, .confirmSend, .keywordFilter, .hideStories:
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
