import Foundation
import UIKit
import Display
import SwiftSignalKit
import TelegramCore
import TelegramPresentationData
import TelegramUIPreferences
import ItemListUI
import PresentationDataUtils
import AccountContext

private final class VeilgramSettingsControllerArguments {
    let update: (VeilgramSettings.Key, Bool) -> Void
    let updateShowCallsTab: (Bool) -> Void

    init(update: @escaping (VeilgramSettings.Key, Bool) -> Void, updateShowCallsTab: @escaping (Bool) -> Void) {
        self.update = update
        self.updateShowCallsTab = updateShowCallsTab
    }
}

private enum VeilgramSettingsSection: Int32 {
    case ghost
    case deleted
    case archive
    case tabs
    case login
}

private enum VeilgramSettingsEntry: ItemListNodeEntry {
    case ghost(Bool)
    case ghostOnline(Bool)
    case ghostTyping(Bool)
    case ghostRead(Bool)
    case ghostStories(Bool)
    case ghostFooter

    case keepDeleted(Bool)
    case deletedIcon(Bool)
    case keepDeletedFooter

    case autoArchive(Bool)
    case autoArchiveGroups(Bool)
    case autoArchiveFooter

    case tabsHeader
    case tabContacts(Bool)
    case tabCalls(Bool)
    case tabNews(Bool)

    case loginButton(Bool)
    case loginButtonFooter

    var section: ItemListSectionId {
        switch self {
        case .ghost, .ghostOnline, .ghostTyping, .ghostRead, .ghostStories, .ghostFooter:
            return VeilgramSettingsSection.ghost.rawValue
        case .keepDeleted, .deletedIcon, .keepDeletedFooter:
            return VeilgramSettingsSection.deleted.rawValue
        case .autoArchive, .autoArchiveGroups, .autoArchiveFooter:
            return VeilgramSettingsSection.archive.rawValue
        case .tabsHeader, .tabContacts, .tabCalls, .tabNews:
            return VeilgramSettingsSection.tabs.rawValue
        case .loginButton, .loginButtonFooter:
            return VeilgramSettingsSection.login.rawValue
        }
    }

    var stableId: Int32 {
        switch self {
        case .ghost:
            return 0
        case .ghostOnline:
            return 1
        case .ghostTyping:
            return 2
        case .ghostRead:
            return 3
        case .ghostStories:
            return 4
        case .ghostFooter:
            return 5
        case .keepDeleted:
            return 10
        case .deletedIcon:
            return 11
        case .keepDeletedFooter:
            return 12
        case .autoArchive:
            return 20
        case .autoArchiveGroups:
            return 21
        case .autoArchiveFooter:
            return 22
        case .tabsHeader:
            return 30
        case .tabContacts:
            return 31
        case .tabCalls:
            return 32
        case .tabNews:
            return 33
        case .loginButton:
            return 40
        case .loginButtonFooter:
            return 41
        }
    }

    static func <(lhs: VeilgramSettingsEntry, rhs: VeilgramSettingsEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }

    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let arguments = arguments as! VeilgramSettingsControllerArguments
        let strings = presentationData.strings

        func switchItem(_ icon: UIImage?, _ key: String, _ title: String, _ value: Bool, _ updated: @escaping (Bool) -> Void) -> ListViewItem {
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, icon: icon, title: veilgramLocalized(strings, key, title), value: value, sectionId: self.section, style: .blocks, updated: updated)
        }
        func footerItem(_ key: String, _ text: String) -> ListViewItem {
            return ItemListTextItem(presentationData: presentationData, text: .plain(veilgramLocalized(strings, key, text)), sectionId: self.section)
        }

        switch self {
        case let .ghost(value):
            return switchItem(VeilgramSettingsIcons.ghost, "Veilgram.Ghost", strings.Veilgram_Ghost, value, { arguments.update(.ghost, $0) })
        case let .ghostOnline(value):
            return switchItem(VeilgramSettingsIcons.ghostOnline, "Veilgram.GhostOnline", strings.Veilgram_GhostOnline, value, { arguments.update(.ghostOnline, $0) })
        case let .ghostTyping(value):
            return switchItem(VeilgramSettingsIcons.ghostTyping, "Veilgram.GhostTyping", strings.Veilgram_GhostTyping, value, { arguments.update(.ghostTyping, $0) })
        case let .ghostRead(value):
            return switchItem(VeilgramSettingsIcons.ghostRead, "Veilgram.GhostRead", strings.Veilgram_GhostRead, value, { arguments.update(.ghostRead, $0) })
        case let .ghostStories(value):
            return switchItem(VeilgramSettingsIcons.ghostStories, "Veilgram.GhostStories", strings.Veilgram_GhostStories, value, { arguments.update(.ghostStories, $0) })
        case .ghostFooter:
            return footerItem("Veilgram.GhostInfo", strings.Veilgram_GhostInfo)
        case let .keepDeleted(value):
            return switchItem(VeilgramSettingsIcons.keepDeleted, "Veilgram.KeepDeleted", strings.Veilgram_KeepDeleted, value, { arguments.update(.keepDeleted, $0) })
        case let .deletedIcon(value):
            return switchItem(VeilgramSettingsIcons.deletedIcon, "Veilgram.DeletedIcon", strings.Veilgram_DeletedIcon, value, { arguments.update(.deletedIcon, $0) })
        case .keepDeletedFooter:
            return footerItem("Veilgram.KeepDeletedInfo", strings.Veilgram_KeepDeletedInfo)
        case let .autoArchive(value):
            return switchItem(VeilgramSettingsIcons.autoArchive, "Veilgram.AutoArchive", strings.Veilgram_AutoArchive, value, { arguments.update(.autoArchive, $0) })
        case let .autoArchiveGroups(value):
            return switchItem(VeilgramSettingsIcons.autoArchiveGroups, "Veilgram.AutoArchiveGroups", strings.Veilgram_AutoArchiveGroups, value, { arguments.update(.autoArchiveGroups, $0) })
        case .autoArchiveFooter:
            return footerItem("Veilgram.AutoArchiveInfo", strings.Veilgram_AutoArchiveInfo)
        case .tabsHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: veilgramLocalized(strings, "Veilgram.Tabs", strings.Veilgram_Tabs).uppercased(), sectionId: self.section)
        case let .tabContacts(value):
            return switchItem(VeilgramSettingsIcons.tabContacts, "Veilgram.TabContacts", strings.Veilgram_TabContacts, value, { arguments.update(.tabContacts, $0) })
        case let .tabCalls(value):
            return switchItem(VeilgramSettingsIcons.tabCalls, "Veilgram.TabCalls", strings.Veilgram_TabCalls, value, { arguments.updateShowCallsTab($0) })
        case let .tabNews(value):
            return switchItem(VeilgramSettingsIcons.tabNews, "Veilgram.TabNews", strings.Veilgram_TabNews, value, { arguments.update(.tabNews, $0) })
        case let .loginButton(value):
            return switchItem(VeilgramSettingsIcons.loginButton, "Veilgram.LoginButton", strings.Veilgram_LoginButton, value, { arguments.update(.loginOpenTelegramButton, $0) })
        case .loginButtonFooter:
            return footerItem("Veilgram.LoginButtonInfo", strings.Veilgram_LoginButtonInfo)
        }
    }
}

/// Sub-options are listed under their switch only while it is on, so they slide in and out with it.
private func veilgramSettingsEntries(showCallsTab: Bool) -> [VeilgramSettingsEntry] {
    var entries: [VeilgramSettingsEntry] = []

    entries.append(.ghost(VeilgramSettings.value(.ghost)))
    if VeilgramSettings.value(.ghost) {
        entries.append(.ghostOnline(VeilgramSettings.value(.ghostOnline)))
        entries.append(.ghostTyping(VeilgramSettings.value(.ghostTyping)))
        entries.append(.ghostRead(VeilgramSettings.value(.ghostRead)))
        entries.append(.ghostStories(VeilgramSettings.value(.ghostStories)))
    }
    entries.append(.ghostFooter)

    entries.append(.keepDeleted(VeilgramSettings.value(.keepDeleted)))
    if VeilgramSettings.value(.keepDeleted) {
        entries.append(.deletedIcon(VeilgramSettings.value(.deletedIcon)))
    }
    entries.append(.keepDeletedFooter)

    entries.append(.autoArchive(VeilgramSettings.value(.autoArchive)))
    if VeilgramSettings.value(.autoArchive) {
        entries.append(.autoArchiveGroups(VeilgramSettings.value(.autoArchiveGroups)))
    }
    entries.append(.autoArchiveFooter)

    entries.append(.tabsHeader)
    entries.append(.tabContacts(VeilgramSettings.value(.tabContacts)))
    entries.append(.tabCalls(showCallsTab))
    entries.append(.tabNews(VeilgramSettings.value(.tabNews)))

    entries.append(.loginButton(VeilgramSettings.value(.loginOpenTelegramButton)))
    entries.append(.loginButtonFooter)

    return entries
}

public func veilgramSettingsController(context: AccountContext) -> ViewController {
    let arguments = VeilgramSettingsControllerArguments(
        update: { key, value in
            VeilgramSettings.set(key, value)
        },
        updateShowCallsTab: { value in
            let _ = updateCallListSettingsInteractively(accountManager: context.sharedContext.accountManager, {
                $0.withUpdatedShowTab(value)
            }).start()
        }
    )

    let showCallsTab = context.sharedContext.accountManager.sharedData(keys: [ApplicationSpecificSharedDataKeys.callListSettings])
    |> map { sharedData -> Bool in
        if let settings = sharedData.entries[ApplicationSpecificSharedDataKeys.callListSettings]?.get(CallListSettings.self) {
            return settings.showTab
        }
        return CallListSettings.defaultSettings.showTab
    }
    |> distinctUntilChanged

    let signal = combineLatest(queue: .mainQueue(),
        context.sharedContext.presentationData,
        showCallsTab,
        VeilgramSettings.updated
    )
    |> map { presentationData, showCallsTab, _ -> (ItemListControllerState, (ItemListNodeState, Any)) in
        let title = veilgramLocalized(presentationData.strings, "Veilgram.Title", presentationData.strings.Veilgram_Title)
        let controllerState = ItemListControllerState(presentationData: ItemListPresentationData(presentationData), title: .text(title), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back))
        let listState = ItemListNodeState(presentationData: ItemListPresentationData(presentationData), entries: veilgramSettingsEntries(showCallsTab: showCallsTab), style: .blocks, animateChanges: true)
        return (controllerState, (listState, arguments))
    }

    return ItemListController(context: context, state: signal)
}
