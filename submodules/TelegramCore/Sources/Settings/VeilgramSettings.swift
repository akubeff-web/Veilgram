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
        case keepDeleted
        case deletedIcon
        case autoArchive
        case autoArchiveGroups
        case tabContacts
        case tabNews
        case loginOpenTelegramButton

        public var defaultValue: Bool {
            switch self {
            case .autoArchiveGroups:
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

    public static var ghostOnline: Bool {
        return value(.ghost) && value(.ghostOnline)
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

    public static var loginOpenTelegramButton: Bool {
        return value(.loginOpenTelegramButton)
    }
}
