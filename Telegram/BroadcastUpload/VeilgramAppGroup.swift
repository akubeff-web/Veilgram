import Foundation

/// The app group shared with the main app (same lookup as TelegramUI's VeilgramAppGroup.swift).
///
/// Telegram uses "group.<bundle id>". Re-signing with a free Apple ID (AltStore, Sideloadly) can give
/// the app a differently named group, and without a container the launch stops before any UI exists
/// (a black screen). The re-signed app carries its provisioning profile, so the groups it was granted
/// are read from there, and the first one with a reachable container is used.
func veilgramAppGroupName(baseAppBundleId: String) -> String {
    let defaultName = "group.\(baseAppBundleId)"
    if FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: defaultName) != nil {
        return defaultName
    }
    for group in veilgramProvisionedAppGroups() where group != defaultName {
        if FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: group) != nil {
            return group
        }
    }
    return defaultName
}

private func veilgramProvisionedAppGroups() -> [String] {
    guard let url = Bundle.main.url(forResource: "embedded", withExtension: "mobileprovision"), let data = try? Data(contentsOf: url) else {
        return []
    }
    // The profile is a signed CMS envelope around a plain XML property list.
    guard let start = data.range(of: Data("<?xml".utf8)), let end = data.range(of: Data("</plist>".utf8), in: start.lowerBound ..< data.endIndex) else {
        return []
    }
    let plistData = data.subdata(in: start.lowerBound ..< end.upperBound)
    guard let plist = (try? PropertyListSerialization.propertyList(from: plistData, options: [], format: nil)) as? [String: Any] else {
        return []
    }
    guard let entitlements = plist["Entitlements"] as? [String: Any], let groups = entitlements["com.apple.security.application-groups"] as? [String] else {
        return []
    }
    return groups
}
