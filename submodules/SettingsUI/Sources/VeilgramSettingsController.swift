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

private final class VeilgramSettingsControllerArguments {
    let update: (VeilgramSettings.Key, Bool) -> Void
    let updateShowCallsTab: (Bool) -> Void
    let openDeletedLog: () -> Void
    let updateKeywords: (String) -> Void
    let updateAutoReplyText: (String) -> Void

    init(update: @escaping (VeilgramSettings.Key, Bool) -> Void, updateShowCallsTab: @escaping (Bool) -> Void, openDeletedLog: @escaping () -> Void, updateKeywords: @escaping (String) -> Void, updateAutoReplyText: @escaping (String) -> Void) {
        self.updateAutoReplyText = updateAutoReplyText
        self.update = update
        self.updateShowCallsTab = updateShowCallsTab
        self.openDeletedLog = openDeletedLog
        self.updateKeywords = updateKeywords
    }
}

private enum VeilgramSettingsSection: Int32 {
    case ghost
    case presence
    case deleted
    case protected
    case filter
    case archive
    case autoReply
    case sending
    case screen
    case premium
    case tabs
    case transfers
    case login
}

private enum VeilgramSettingsEntry: ItemListNodeEntry {
    case ghost(Bool)
    case ghostOnline(Bool)
    case ghostTyping(Bool)
    case ghostRead(Bool)
    case ghostStories(Bool)
    case ghostFooter

    case alwaysOnline(Bool)
    case alwaysOnlineFooter

    case deletedHeader
    case keepDeleted(Bool)
    case deletedIcon(Bool)
    case editHistory(Bool)
    case preloadMedia(Bool)
    case preloadMediaGroups(Bool)
    case deletedLog
    case keepDeletedFooter

    case newChatsHeader
    case autoArchive(Bool)
    case autoArchiveGroups(Bool)
    case autoArchiveFooter

    case confirmSend(Bool)
    case confirmSendFooter

    case autoReply(Bool)
    case autoReplyText(String)
    case autoReplyContacts(Bool)
    case autoReplyFooter

    case filterHeader
    case hideBlocked(Bool)
    case keywordFilter(Bool)
    case keywords(String)
    case filterFooter

    case protectedHeader
    case unlockProtected(Bool)
    case keepViewOnce(Bool)
    case protectedFooter

    case screenHeader
    case streamerMode(Bool)
    case hidePhone(Bool)
    case screenFooter

    case premiumHeader
    case hidePremiumBadges(Bool)
    case hidePremiumBanners(Bool)
    case hidePremiumOffers(Bool)
    case hideGifts(Bool)

    case otherHeader
    case fastTransfers(Bool)
    case fastTransfersFooter

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
        case .alwaysOnline, .alwaysOnlineFooter:
            return VeilgramSettingsSection.presence.rawValue
        case .deletedHeader, .keepDeleted, .deletedIcon, .editHistory, .preloadMedia, .preloadMediaGroups, .deletedLog, .keepDeletedFooter:
            return VeilgramSettingsSection.deleted.rawValue
        case .protectedHeader, .unlockProtected, .keepViewOnce, .protectedFooter:
            return VeilgramSettingsSection.protected.rawValue
        case .filterHeader, .hideBlocked, .keywordFilter, .keywords, .filterFooter:
            return VeilgramSettingsSection.filter.rawValue
        case .newChatsHeader, .autoArchive, .autoArchiveGroups, .autoArchiveFooter:
            return VeilgramSettingsSection.archive.rawValue
        case .autoReply, .autoReplyText, .autoReplyContacts, .autoReplyFooter:
            return VeilgramSettingsSection.autoReply.rawValue
        case .confirmSend, .confirmSendFooter:
            return VeilgramSettingsSection.sending.rawValue
        case .screenHeader, .streamerMode, .hidePhone, .screenFooter:
            return VeilgramSettingsSection.screen.rawValue
        case .premiumHeader, .hidePremiumBadges, .hidePremiumBanners, .hidePremiumOffers, .hideGifts:
            return VeilgramSettingsSection.premium.rawValue
        case .tabsHeader, .tabContacts, .tabCalls, .tabNews, .hideStories:
            return VeilgramSettingsSection.tabs.rawValue
        case .otherHeader, .fastTransfers, .fastTransfersFooter:
            return VeilgramSettingsSection.transfers.rawValue
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
        case .alwaysOnline:
            return 6
        case .alwaysOnlineFooter:
            return 7
        case .deletedHeader:
            return 8
        case .keepDeleted:
            return 9
        case .deletedIcon:
            return 10
        case .editHistory:
            return 11
        case .preloadMedia:
            return 12
        case .preloadMediaGroups:
            return 13
        case .deletedLog:
            return 14
        case .keepDeletedFooter:
            return 15
        case .protectedHeader:
            return 16
        case .unlockProtected:
            return 17
        case .keepViewOnce:
            return 18
        case .protectedFooter:
            return 19
        case .filterHeader:
            return 20
        case .hideBlocked:
            return 21
        case .keywordFilter:
            return 22
        case .keywords:
            return 23
        case .filterFooter:
            return 24
        case .newChatsHeader:
            return 25
        case .autoArchive:
            return 26
        case .autoArchiveGroups:
            return 27
        case .autoArchiveFooter:
            return 28
        case .autoReply:
            return 29
        case .autoReplyText:
            return 30
        case .autoReplyContacts:
            return 31
        case .autoReplyFooter:
            return 32
        case .confirmSend:
            return 33
        case .confirmSendFooter:
            return 34
        case .screenHeader:
            return 35
        case .streamerMode:
            return 36
        case .hidePhone:
            return 37
        case .screenFooter:
            return 38
        case .premiumHeader:
            return 39
        case .hidePremiumBadges:
            return 40
        case .hidePremiumBanners:
            return 41
        case .hidePremiumOffers:
            return 42
        case .hideGifts:
            return 43
        case .tabsHeader:
            return 44
        case .tabContacts:
            return 45
        case .tabCalls:
            return 46
        case .tabNews:
            return 47
        case .hideStories:
            return 48
        case .otherHeader:
            return 49
        case .fastTransfers:
            return 50
        case .fastTransfersFooter:
            return 51
        case .loginButton:
            return 52
        case .loginButtonFooter:
            return 53
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
        case .deletedHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: veilgramLocalized(strings, "Veilgram.DeletedHeader", strings.Veilgram_DeletedHeader).uppercased(), sectionId: self.section)
        case .protectedHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: veilgramLocalized(strings, "Veilgram.ProtectedHeader", strings.Veilgram_ProtectedHeader).uppercased(), sectionId: self.section)
        case .filterHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: veilgramLocalized(strings, "Veilgram.FilterHeader", strings.Veilgram_FilterHeader).uppercased(), sectionId: self.section)
        case .newChatsHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: veilgramLocalized(strings, "Veilgram.NewChatsHeader", strings.Veilgram_NewChatsHeader).uppercased(), sectionId: self.section)
        case .screenHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: veilgramLocalized(strings, "Veilgram.ScreenHeader", strings.Veilgram_ScreenHeader).uppercased(), sectionId: self.section)
        case .otherHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: veilgramLocalized(strings, "Veilgram.OtherHeader", strings.Veilgram_OtherHeader).uppercased(), sectionId: self.section)
        case let .alwaysOnline(value):
            return switchItem(VeilgramSettingsIcons.alwaysOnline, "Veilgram.AlwaysOnline", strings.Veilgram_AlwaysOnline, value, { arguments.update(.alwaysOnline, $0) })
        case .alwaysOnlineFooter:
            return footerItem("Veilgram.AlwaysOnlineInfo", strings.Veilgram_AlwaysOnlineInfo)
        case let .keepDeleted(value):
            return switchItem(VeilgramSettingsIcons.keepDeleted, "Veilgram.KeepDeleted", strings.Veilgram_KeepDeleted, value, { arguments.update(.keepDeleted, $0) })
        case let .deletedIcon(value):
            return switchItem(VeilgramSettingsIcons.deletedIcon, "Veilgram.DeletedIcon", strings.Veilgram_DeletedIcon, value, { arguments.update(.deletedIcon, $0) })
        case let .preloadMedia(value):
            return switchItem(VeilgramSettingsIcons.preloadMedia, "Veilgram.PreloadMedia", strings.Veilgram_PreloadMedia, value, { arguments.update(.preloadMedia, $0) })
        case let .preloadMediaGroups(value):
            return switchItem(VeilgramSettingsIcons.preloadMediaGroups, "Veilgram.PreloadMediaGroups", strings.Veilgram_PreloadMediaGroups, value, { arguments.update(.preloadMediaGroups, $0) })
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
        case let .autoReply(value):
            return switchItem(VeilgramSettingsIcons.autoReply, "Veilgram.AutoReply", strings.Veilgram_AutoReply, value, { arguments.update(.autoReply, $0) })
        case let .autoReplyText(text):
            return ItemListMultilineInputItem(presentationData: presentationData, systemStyle: .glass, text: text, placeholder: veilgramLocalized(strings, "Veilgram.AutoReplyPlaceholder", strings.Veilgram_AutoReplyPlaceholder), maxLength: ItemListMultilineInputItemTextLimit(value: 4096, display: false), sectionId: self.section, style: .blocks, textUpdated: { text in
                arguments.updateAutoReplyText(text)
            })
        case let .autoReplyContacts(value):
            return switchItem(VeilgramSettingsIcons.autoReplyContacts, "Veilgram.AutoReplyContacts", strings.Veilgram_AutoReplyContacts, value, { arguments.update(.autoReplyContacts, $0) })
        case .autoReplyFooter:
            return footerItem("Veilgram.AutoReplyInfo", strings.Veilgram_AutoReplyInfo)
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
        case .premiumHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: veilgramLocalized(strings, "Veilgram.PremiumHeader", strings.Veilgram_PremiumHeader).uppercased(), sectionId: self.section)
        case let .hidePremiumBadges(value):
            return switchItem(VeilgramSettingsIcons.premiumItem, "Veilgram.HidePremiumBadges", strings.Veilgram_HidePremiumBadges, value, { arguments.update(.hidePremiumBadges, $0) })
        case let .hidePremiumBanners(value):
            return switchItem(VeilgramSettingsIcons.premiumItem, "Veilgram.HidePremiumBanners", strings.Veilgram_HidePremiumBanners, value, { arguments.update(.hidePremiumBanners, $0) })
        case let .hidePremiumOffers(value):
            return switchItem(VeilgramSettingsIcons.premiumItem, "Veilgram.HidePremiumOffers", strings.Veilgram_HidePremiumOffers, value, { arguments.update(.hidePremiumOffers, $0) })
        case let .hideGifts(value):
            return switchItem(VeilgramSettingsIcons.premiumItem, "Veilgram.HideGifts", strings.Veilgram_HideGifts, value, { arguments.update(.hideGifts, $0) })
        case let .fastTransfers(value):
            return switchItem(VeilgramSettingsIcons.fastTransfers, "Veilgram.FastTransfers", strings.Veilgram_FastTransfers, value, { arguments.update(.fastTransfers, $0) })
        case .fastTransfersFooter:
            return footerItem("Veilgram.FastTransfersInfo", strings.Veilgram_FastTransfersInfo)
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

    entries.append(.alwaysOnline(VeilgramSettings.value(.alwaysOnline)))
    entries.append(.alwaysOnlineFooter)

    entries.append(.deletedHeader)
    entries.append(.keepDeleted(VeilgramSettings.value(.keepDeleted)))
    if VeilgramSettings.value(.keepDeleted) {
        entries.append(.deletedIcon(VeilgramSettings.value(.deletedIcon)))
    }
    entries.append(.editHistory(VeilgramSettings.value(.editHistory)))
    entries.append(.preloadMedia(VeilgramSettings.value(.preloadMedia)))
    if VeilgramSettings.value(.preloadMedia) {
        entries.append(.preloadMediaGroups(VeilgramSettings.value(.preloadMediaGroups)))
    }
    entries.append(.deletedLog)
    entries.append(.keepDeletedFooter)

    entries.append(.protectedHeader)
    entries.append(.unlockProtected(VeilgramSettings.value(.unlockProtected)))
    entries.append(.keepViewOnce(VeilgramSettings.value(.keepViewOnce)))
    entries.append(.protectedFooter)

    entries.append(.filterHeader)
    entries.append(.hideBlocked(VeilgramSettings.value(.hideBlocked)))
    entries.append(.keywordFilter(VeilgramSettings.value(.keywordFilter)))
    if VeilgramSettings.value(.keywordFilter) {
        entries.append(.keywords(VeilgramSettings.filterKeywordsText))
    }
    entries.append(.filterFooter)

    entries.append(.newChatsHeader)
    entries.append(.autoArchive(VeilgramSettings.value(.autoArchive)))
    if VeilgramSettings.value(.autoArchive) {
        entries.append(.autoArchiveGroups(VeilgramSettings.value(.autoArchiveGroups)))
    }
    entries.append(.autoArchiveFooter)

    entries.append(.autoReply(VeilgramSettings.value(.autoReply)))
    if VeilgramSettings.value(.autoReply) {
        entries.append(.autoReplyText(VeilgramSettings.autoReplyRawText))
        entries.append(.autoReplyContacts(VeilgramSettings.value(.autoReplyContacts)))
    }
    entries.append(.autoReplyFooter)

    entries.append(.confirmSend(VeilgramSettings.value(.confirmSend)))
    entries.append(.confirmSendFooter)

    entries.append(.screenHeader)
    entries.append(.streamerMode(VeilgramSettings.value(.streamerMode)))
    entries.append(.hidePhone(VeilgramSettings.value(.hidePhone)))
    entries.append(.screenFooter)

    entries.append(.premiumHeader)
    entries.append(.hidePremiumBadges(VeilgramSettings.value(.hidePremiumBadges)))
    entries.append(.hidePremiumBanners(VeilgramSettings.value(.hidePremiumBanners)))
    entries.append(.hidePremiumOffers(VeilgramSettings.value(.hidePremiumOffers)))
    entries.append(.hideGifts(VeilgramSettings.value(.hideGifts)))

    entries.append(.tabsHeader)
    entries.append(.tabContacts(VeilgramSettings.value(.tabContacts)))
    entries.append(.tabCalls(showCallsTab))
    entries.append(.tabNews(VeilgramSettings.value(.tabNews)))
    entries.append(.hideStories(VeilgramSettings.value(.hideStories)))

    entries.append(.otherHeader)
    entries.append(.fastTransfers(VeilgramSettings.value(.fastTransfers)))
    entries.append(.fastTransfersFooter)

    entries.append(.loginButton(VeilgramSettings.value(.loginOpenTelegramButton)))
    entries.append(.loginButtonFooter)

    return entries
}

public func veilgramSettingsController(context: AccountContext) -> ViewController {
    var pushImpl: ((ViewController) -> Void)?
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
        updateAutoReplyText: { text in
            VeilgramSettings.setAutoReplyText(text)
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
    return controller
}
