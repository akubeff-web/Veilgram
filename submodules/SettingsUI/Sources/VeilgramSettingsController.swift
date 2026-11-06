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
import LocalizedPeerData
import UndoUI

private final class VeilgramSettingsControllerArguments {
    let update: (VeilgramSettings.Key, Bool) -> Void
    let updateShowCallsTab: (Bool) -> Void
    let openDeletedLog: () -> Void
    let updateKeywords: (String) -> Void
    let readAllChats: () -> Void

    init(update: @escaping (VeilgramSettings.Key, Bool) -> Void, updateShowCallsTab: @escaping (Bool) -> Void, openDeletedLog: @escaping () -> Void, updateKeywords: @escaping (String) -> Void, readAllChats: @escaping () -> Void) {
        self.readAllChats = readAllChats
        self.update = update
        self.updateShowCallsTab = updateShowCallsTab
        self.openDeletedLog = openDeletedLog
        self.updateKeywords = updateKeywords
    }
}

private enum VeilgramSettingsSection: Int32 {
    case ghost
    case readAll
    case presence
    case deleted
    case archive
    case sending
    case filter
    case protected
    case screen
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

    case readAllChats

    case alwaysOnline(Bool)
    case alwaysOnlineFooter

    case keepDeleted(Bool)
    case deletedIcon(Bool)
    case editHistory(Bool)
    case deletedLog
    case keepDeletedFooter

    case autoArchive(Bool)
    case autoArchiveGroups(Bool)
    case autoArchiveFooter

    case confirmSend(Bool)
    case confirmSendFooter

    case hideBlocked(Bool)
    case keywordFilter(Bool)
    case keywords(String)
    case filterFooter

    case unlockProtected(Bool)
    case keepViewOnce(Bool)
    case protectedFooter

    case streamerMode(Bool)
    case hidePhone(Bool)
    case screenFooter

    case tabsHeader
    case tabContacts(Bool)
    case tabCalls(Bool)
    case tabNews(Bool)
    case hideStories(Bool)

    case loginButton(Bool)
    case loginButtonFooter

    var section: ItemListSectionId {
        switch self {
        case .ghost, .ghostOnline, .ghostTyping, .ghostRead, .ghostStories, .ghostFooter:
            return VeilgramSettingsSection.ghost.rawValue
        case .readAllChats:
            return VeilgramSettingsSection.readAll.rawValue
        case .alwaysOnline, .alwaysOnlineFooter:
            return VeilgramSettingsSection.presence.rawValue
        case .keepDeleted, .deletedIcon, .editHistory, .deletedLog, .keepDeletedFooter:
            return VeilgramSettingsSection.deleted.rawValue
        case .autoArchive, .autoArchiveGroups, .autoArchiveFooter:
            return VeilgramSettingsSection.archive.rawValue
        case .confirmSend, .confirmSendFooter:
            return VeilgramSettingsSection.sending.rawValue
        case .hideBlocked, .keywordFilter, .keywords, .filterFooter:
            return VeilgramSettingsSection.filter.rawValue
        case .unlockProtected, .keepViewOnce, .protectedFooter:
            return VeilgramSettingsSection.protected.rawValue
        case .streamerMode, .hidePhone, .screenFooter:
            return VeilgramSettingsSection.screen.rawValue
        case .tabsHeader, .tabContacts, .tabCalls, .tabNews, .hideStories:
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
        case .readAllChats:
            return 6
        case .alwaysOnline:
            return 7
        case .alwaysOnlineFooter:
            return 8
        case .keepDeleted:
            return 10
        case .deletedIcon:
            return 11
        case .editHistory:
            return 12
        case .deletedLog:
            return 13
        case .keepDeletedFooter:
            return 14
        case .autoArchive:
            return 20
        case .autoArchiveGroups:
            return 21
        case .autoArchiveFooter:
            return 22
        case .confirmSend:
            return 25
        case .confirmSendFooter:
            return 26
        case .hideBlocked:
            return 30
        case .keywordFilter:
            return 31
        case .keywords:
            return 32
        case .filterFooter:
            return 33
        case .unlockProtected:
            return 35
        case .keepViewOnce:
            return 36
        case .protectedFooter:
            return 37
        case .streamerMode:
            return 38
        case .hidePhone:
            return 39
        case .screenFooter:
            return 40
        case .tabsHeader:
            return 50
        case .tabContacts:
            return 51
        case .tabCalls:
            return 52
        case .tabNews:
            return 53
        case .hideStories:
            return 54
        case .loginButton:
            return 60
        case .loginButtonFooter:
            return 61
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
        case .readAllChats:
            return ItemListActionItem(presentationData: presentationData, systemStyle: .glass, title: veilgramLocalized(strings, "Veilgram.ReadAllChats", strings.Veilgram_ReadAllChats), kind: .generic, alignment: .natural, sectionId: self.section, style: .blocks, action: {
                arguments.readAllChats()
            })
        case let .alwaysOnline(value):
            return switchItem(VeilgramSettingsIcons.alwaysOnline, "Veilgram.AlwaysOnline", strings.Veilgram_AlwaysOnline, value, { arguments.update(.alwaysOnline, $0) })
        case .alwaysOnlineFooter:
            return footerItem("Veilgram.AlwaysOnlineInfo", strings.Veilgram_AlwaysOnlineInfo)
        case let .keepDeleted(value):
            return switchItem(VeilgramSettingsIcons.keepDeleted, "Veilgram.KeepDeleted", strings.Veilgram_KeepDeleted, value, { arguments.update(.keepDeleted, $0) })
        case let .deletedIcon(value):
            return switchItem(VeilgramSettingsIcons.deletedIcon, "Veilgram.DeletedIcon", strings.Veilgram_DeletedIcon, value, { arguments.update(.deletedIcon, $0) })
        case let .editHistory(value):
            return switchItem(VeilgramSettingsIcons.editHistory, "Veilgram.EditHistorySetting", strings.Veilgram_EditHistorySetting, value, { arguments.update(.editHistory, $0) })
        case .deletedLog:
            return ItemListDisclosureItem(presentationData: presentationData, systemStyle: .glass, icon: VeilgramSettingsIcons.deletedLog, title: veilgramLocalized(strings, "Veilgram.DeletedLog", strings.Veilgram_DeletedLog), label: "", sectionId: self.section, style: .blocks, action: {
                arguments.openDeletedLog()
            })
        case .keepDeletedFooter:
            return footerItem("Veilgram.KeepDeletedInfo", strings.Veilgram_KeepDeletedInfo)
        case let .autoArchive(value):
            return switchItem(VeilgramSettingsIcons.autoArchive, "Veilgram.AutoArchive", strings.Veilgram_AutoArchive, value, { arguments.update(.autoArchive, $0) })
        case let .autoArchiveGroups(value):
            return switchItem(VeilgramSettingsIcons.autoArchiveGroups, "Veilgram.AutoArchiveGroups", strings.Veilgram_AutoArchiveGroups, value, { arguments.update(.autoArchiveGroups, $0) })
        case .autoArchiveFooter:
            return footerItem("Veilgram.AutoArchiveInfo", strings.Veilgram_AutoArchiveInfo)
        case let .confirmSend(value):
            return switchItem(VeilgramSettingsIcons.confirmSend, "Veilgram.ConfirmSend", strings.Veilgram_ConfirmSend, value, { arguments.update(.confirmSend, $0) })
        case .confirmSendFooter:
            return footerItem("Veilgram.ConfirmSendInfo", strings.Veilgram_ConfirmSendInfo)
        case let .hideBlocked(value):
            return switchItem(VeilgramSettingsIcons.hideBlocked, "Veilgram.HideBlocked", strings.Veilgram_HideBlocked, value, { arguments.update(.hideBlocked, $0) })
        case let .keywordFilter(value):
            return switchItem(VeilgramSettingsIcons.keywordFilter, "Veilgram.KeywordFilter", strings.Veilgram_KeywordFilter, value, { arguments.update(.keywordFilter, $0) })
        case let .keywords(text):
            return ItemListMultilineInputItem(presentationData: presentationData, systemStyle: .glass, text: text, placeholder: veilgramLocalized(strings, "Veilgram.KeywordsPlaceholder", strings.Veilgram_KeywordsPlaceholder), maxLength: nil, sectionId: self.section, style: .blocks, capitalization: false, autocorrection: false, textUpdated: { text in
                arguments.updateKeywords(text)
            })
        case .filterFooter:
            return footerItem("Veilgram.FilterInfo", strings.Veilgram_FilterInfo)
        case let .unlockProtected(value):
            return switchItem(VeilgramSettingsIcons.unlockProtected, "Veilgram.UnlockProtected", strings.Veilgram_UnlockProtected, value, { arguments.update(.unlockProtected, $0) })
        case let .keepViewOnce(value):
            return switchItem(VeilgramSettingsIcons.keepViewOnce, "Veilgram.KeepViewOnce", strings.Veilgram_KeepViewOnce, value, { arguments.update(.keepViewOnce, $0) })
        case .protectedFooter:
            return footerItem("Veilgram.ProtectedInfo", strings.Veilgram_ProtectedInfo)
        case let .streamerMode(value):
            return switchItem(VeilgramSettingsIcons.streamerMode, "Veilgram.StreamerMode", strings.Veilgram_StreamerMode, value, { arguments.update(.streamerMode, $0) })
        case let .hidePhone(value):
            return switchItem(VeilgramSettingsIcons.hidePhone, "Veilgram.HidePhone", strings.Veilgram_HidePhone, value, { arguments.update(.hidePhone, $0) })
        case .screenFooter:
            return footerItem("Veilgram.ScreenInfo", strings.Veilgram_ScreenInfo)
        case .tabsHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: veilgramLocalized(strings, "Veilgram.Tabs", strings.Veilgram_Tabs).uppercased(), sectionId: self.section)
        case let .tabContacts(value):
            return switchItem(VeilgramSettingsIcons.tabContacts, "Veilgram.TabContacts", strings.Veilgram_TabContacts, value, { arguments.update(.tabContacts, $0) })
        case let .tabCalls(value):
            return switchItem(VeilgramSettingsIcons.tabCalls, "Veilgram.TabCalls", strings.Veilgram_TabCalls, value, { arguments.updateShowCallsTab($0) })
        case let .tabNews(value):
            return switchItem(VeilgramSettingsIcons.tabNews, "Veilgram.TabNews", strings.Veilgram_TabNews, value, { arguments.update(.tabNews, $0) })
        case let .hideStories(value):
            return switchItem(VeilgramSettingsIcons.hideStories, "Veilgram.HideStories", strings.Veilgram_HideStories, value, { arguments.update(.hideStories, $0) })
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

    entries.append(.readAllChats)

    entries.append(.alwaysOnline(VeilgramSettings.value(.alwaysOnline)))
    entries.append(.alwaysOnlineFooter)

    entries.append(.keepDeleted(VeilgramSettings.value(.keepDeleted)))
    if VeilgramSettings.value(.keepDeleted) {
        entries.append(.deletedIcon(VeilgramSettings.value(.deletedIcon)))
    }
    entries.append(.editHistory(VeilgramSettings.value(.editHistory)))
    entries.append(.deletedLog)
    entries.append(.keepDeletedFooter)

    entries.append(.autoArchive(VeilgramSettings.value(.autoArchive)))
    if VeilgramSettings.value(.autoArchive) {
        entries.append(.autoArchiveGroups(VeilgramSettings.value(.autoArchiveGroups)))
    }
    entries.append(.autoArchiveFooter)

    entries.append(.confirmSend(VeilgramSettings.value(.confirmSend)))
    entries.append(.confirmSendFooter)

    entries.append(.hideBlocked(VeilgramSettings.value(.hideBlocked)))
    entries.append(.keywordFilter(VeilgramSettings.value(.keywordFilter)))
    if VeilgramSettings.value(.keywordFilter) {
        entries.append(.keywords(VeilgramSettings.filterKeywordsText))
    }
    entries.append(.filterFooter)

    entries.append(.unlockProtected(VeilgramSettings.value(.unlockProtected)))
    entries.append(.keepViewOnce(VeilgramSettings.value(.keepViewOnce)))
    entries.append(.protectedFooter)

    entries.append(.streamerMode(VeilgramSettings.value(.streamerMode)))
    entries.append(.hidePhone(VeilgramSettings.value(.hidePhone)))
    entries.append(.screenFooter)

    entries.append(.tabsHeader)
    entries.append(.tabContacts(VeilgramSettings.value(.tabContacts)))
    entries.append(.tabCalls(showCallsTab))
    entries.append(.tabNews(VeilgramSettings.value(.tabNews)))
    entries.append(.hideStories(VeilgramSettings.value(.hideStories)))

    entries.append(.loginButton(VeilgramSettings.value(.loginOpenTelegramButton)))
    entries.append(.loginButtonFooter)

    return entries
}

public func veilgramSettingsController(context: AccountContext) -> ViewController {
    var pushImpl: ((ViewController) -> Void)?
    var presentImpl: ((ViewController) -> Void)?
    let arguments = VeilgramSettingsControllerArguments(
        update: { key, value in
            VeilgramSettings.set(key, value)
        },
        updateShowCallsTab: { value in
            let _ = updateCallListSettingsInteractively(accountManager: context.sharedContext.accountManager, {
                $0.withUpdatedShowTab(value)
            }).start()
        },
        openDeletedLog: {
            let log = veilgramDeletedMessagesLog(accountPeerId: context.account.peerId)
            let _ = (context.engine.data.get(EngineDataMap(log.map { TelegramEngine.EngineData.Item.Messages.Message(id: $0.id) }))
            |> deliverOnMainQueue).start(next: { messages in
                let strings = context.sharedContext.currentPresentationData.with { $0 }.strings
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                formatter.timeStyle = .short
                var rows: [(label: String, value: String, open: ((ViewController) -> Void)?)] = []
                for entry in log {
                    guard let maybeMessage = messages[entry.id], let message = maybeMessage else {
                        continue
                    }
                    var title = message.enginePeers[message.id.peerId]?.compactDisplayTitle ?? ""
                    if let author = message.author, author.id != message.id.peerId {
                        title += " · " + author.compactDisplayTitle
                    }
                    let date = formatter.string(from: Date(timeIntervalSince1970: Double(entry.date)))
                    let text = message.text.isEmpty ? veilgramLocalized(strings, "Veilgram.Media", strings.Veilgram_Media) : message.text
                    let messageId = message.id
                    let chatPeer = message.enginePeers[message.id.peerId]
                    rows.append(("\(title) · \(date)", text, { controller in
                        guard let chatPeer, let navigationController = controller.navigationController as? NavigationController else {
                            return
                        }
                        context.sharedContext.navigateToChatController(NavigateToChatControllerParams(navigationController: navigationController, context: context, chatLocation: .peer(chatPeer), subject: .message(id: .id(messageId), highlight: ChatControllerSubject.MessageHighlight(quote: nil), timecode: nil, setupReply: false), keepStack: .always, useExisting: true))
                    }))
                }
                if rows.isEmpty {
                    rows.append(("", veilgramLocalized(strings, "Veilgram.DeletedLogEmpty", strings.Veilgram_DeletedLogEmpty), nil))
                }
                pushImpl?(veilgramRowsController(context: context, title: veilgramLocalized(strings, "Veilgram.DeletedLog", strings.Veilgram_DeletedLog), rows: rows))
            })
        },
        updateKeywords: { text in
            VeilgramSettings.setFilterKeywordsText(text)
        },
        readAllChats: {
            let _ = (veilgramReadAllChats(account: context.account)
            |> deliverOnMainQueue).start(completed: {
                let presentationData = context.sharedContext.currentPresentationData.with { $0 }
                presentImpl?(UndoOverlayController(presentationData: presentationData, content: .succeed(text: veilgramLocalized(presentationData.strings, "Veilgram.ReadAllChatsDone", presentationData.strings.Veilgram_ReadAllChatsDone), timeout: nil, customUndoText: nil), elevatedLayout: false, action: { _ in
                    return false
                }))
            })
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

    let controller = ItemListController(context: context, state: signal)
    pushImpl = { [weak controller] c in
        controller?.push(c)
    }
    presentImpl = { [weak controller] c in
        controller?.present(c, in: .current)
    }
    return controller
}
