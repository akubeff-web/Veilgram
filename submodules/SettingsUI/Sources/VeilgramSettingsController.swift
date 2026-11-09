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
    let updateGhostThisAccount: (Bool) -> Void
    let updateShowCallsTab: (Bool) -> Void
    let openDeletedLog: () -> Void
    let updateKeywords: (String) -> Void
    let updateAutoReplyText: (String) -> Void
    let chooseBanner: (VeilgramSettings.ProfileBannerKind) -> Void
    let removeBanner: () -> Void

    init(update: @escaping (VeilgramSettings.Key, Bool) -> Void, updateGhostThisAccount: @escaping (Bool) -> Void, updateShowCallsTab: @escaping (Bool) -> Void, openDeletedLog: @escaping () -> Void, updateKeywords: @escaping (String) -> Void, updateAutoReplyText: @escaping (String) -> Void, chooseBanner: @escaping (VeilgramSettings.ProfileBannerKind) -> Void, removeBanner: @escaping () -> Void) {
        self.chooseBanner = chooseBanner
        self.removeBanner = removeBanner
        self.updateAutoReplyText = updateAutoReplyText
        self.update = update
        self.updateGhostThisAccount = updateGhostThisAccount
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
    case banner
    case premium
    case tabs
    case transfers
    case login
}

private enum VeilgramSettingsEntry: ItemListNodeEntry {
    case ghost(Bool)
    case ghostThisAccount(Bool)
    case ghostOnline(Bool)
    case ghostTyping(Bool)
    case ghostRead(Bool)
    case ghostStories(Bool)
    case readOnReply(Bool)
    case ghostOfflineSend(Bool)
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
    case confirmLinks(Bool)
    case confirmSendFooter

    case autoReply(Bool)
    case autoReplyText(String)
    case autoReplyContacts(Bool)
    case autoReplyFooter

    case filterHeader
    case hideBlocked(Bool)
    case keywordFilter(Bool)
    case keywords(String)
    case hideSponsored(Bool)
    case filterFooter

    case protectedHeader
    case unlockProtected(Bool)
    case keepViewOnce(Bool)
    case protectedFooter

    case screenHeader
    case streamerMode(Bool)
    case hidePhone(Bool)
    case hideUsername(Bool)
    case hideChatListTime(Bool)
    case hideChatListPreviews(Bool)
    case screenFooter

    case bannerHeader
    case bannerColor
    case bannerPhoto
    case bannerVideo
    case bannerRemove
    case bannerFooter

    case premiumHeader
    case hidePremiumBadges(Bool)
    case hidePremiumBanners(Bool)
    case hidePremiumOffers(Bool)
    case hideGifts(Bool)

    case otherHeader
    case localTranscription(Bool)
    case localTranslation(Bool)
    case quietHours(Bool)
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
        case .ghost, .ghostThisAccount, .ghostOnline, .ghostTyping, .ghostRead, .ghostStories, .readOnReply, .ghostOfflineSend, .ghostFooter:
            return VeilgramSettingsSection.ghost.rawValue
        case .alwaysOnline, .alwaysOnlineFooter:
            return VeilgramSettingsSection.presence.rawValue
        case .deletedHeader, .keepDeleted, .deletedIcon, .editHistory, .preloadMedia, .preloadMediaGroups, .deletedLog, .keepDeletedFooter:
            return VeilgramSettingsSection.deleted.rawValue
        case .protectedHeader, .unlockProtected, .keepViewOnce, .protectedFooter:
            return VeilgramSettingsSection.protected.rawValue
        case .filterHeader, .hideBlocked, .keywordFilter, .keywords, .hideSponsored, .filterFooter:
            return VeilgramSettingsSection.filter.rawValue
        case .newChatsHeader, .autoArchive, .autoArchiveGroups, .autoArchiveFooter:
            return VeilgramSettingsSection.archive.rawValue
        case .autoReply, .autoReplyText, .autoReplyContacts, .autoReplyFooter:
            return VeilgramSettingsSection.autoReply.rawValue
        case .confirmSend, .confirmLinks, .confirmSendFooter:
            return VeilgramSettingsSection.sending.rawValue
        case .screenHeader, .streamerMode, .hidePhone, .hideUsername, .hideChatListTime, .hideChatListPreviews, .screenFooter:
            return VeilgramSettingsSection.screen.rawValue
        case .bannerHeader, .bannerColor, .bannerPhoto, .bannerVideo, .bannerRemove, .bannerFooter:
            return VeilgramSettingsSection.banner.rawValue
        case .premiumHeader, .hidePremiumBadges, .hidePremiumBanners, .hidePremiumOffers, .hideGifts:
            return VeilgramSettingsSection.premium.rawValue
        case .tabsHeader, .tabContacts, .tabCalls, .tabNews, .hideStories:
            return VeilgramSettingsSection.tabs.rawValue
        case .otherHeader, .localTranscription, .localTranslation, .quietHours, .fastTransfers, .fastTransfersFooter:
            return VeilgramSettingsSection.transfers.rawValue
        case .loginButton, .loginButtonFooter:
            return VeilgramSettingsSection.login.rawValue
        }
    }

    var stableId: Int32 {
        switch self {
        case .ghost:
            return 0
        case .ghostThisAccount:
            return 1
        case .ghostOnline:
            return 2
        case .ghostTyping:
            return 3
        case .ghostRead:
            return 4
        case .ghostStories:
            return 5
        case .readOnReply:
            return 6
        case .ghostOfflineSend:
            return 7
        case .ghostFooter:
            return 8
        case .alwaysOnline:
            return 9
        case .alwaysOnlineFooter:
            return 10
        case .deletedHeader:
            return 11
        case .keepDeleted:
            return 12
        case .deletedIcon:
            return 13
        case .editHistory:
            return 14
        case .preloadMedia:
            return 15
        case .preloadMediaGroups:
            return 16
        case .deletedLog:
            return 17
        case .keepDeletedFooter:
            return 18
        case .protectedHeader:
            return 19
        case .unlockProtected:
            return 20
        case .keepViewOnce:
            return 21
        case .protectedFooter:
            return 22
        case .filterHeader:
            return 23
        case .hideBlocked:
            return 24
        case .keywordFilter:
            return 25
        case .keywords:
            return 26
        case .hideSponsored:
            return 27
        case .filterFooter:
            return 28
        case .newChatsHeader:
            return 29
        case .autoArchive:
            return 30
        case .autoArchiveGroups:
            return 31
        case .autoArchiveFooter:
            return 32
        case .autoReply:
            return 33
        case .autoReplyText:
            return 34
        case .autoReplyContacts:
            return 35
        case .autoReplyFooter:
            return 36
        case .confirmSend:
            return 37
        case .confirmLinks:
            return 38
        case .confirmSendFooter:
            return 39
        case .screenHeader:
            return 40
        case .streamerMode:
            return 41
        case .hidePhone:
            return 42
        case .hideUsername:
            return 43
        case .hideChatListTime:
            return 44
        case .hideChatListPreviews:
            return 45
        case .screenFooter:
            return 46
        case .bannerHeader:
            return 47
        case .bannerColor:
            return 48
        case .bannerPhoto:
            return 49
        case .bannerVideo:
            return 50
        case .bannerRemove:
            return 51
        case .bannerFooter:
            return 52
        case .premiumHeader:
            return 53
        case .hidePremiumBadges:
            return 54
        case .hidePremiumBanners:
            return 55
        case .hidePremiumOffers:
            return 56
        case .hideGifts:
            return 57
        case .tabsHeader:
            return 58
        case .tabContacts:
            return 59
        case .tabCalls:
            return 60
        case .tabNews:
            return 61
        case .hideStories:
            return 62
        case .otherHeader:
            return 63
        case .localTranscription:
            return 64
        case .localTranslation:
            return 65
        case .quietHours:
            return 66
        case .fastTransfers:
            return 67
        case .fastTransfersFooter:
            return 68
        case .loginButton:
            return 69
        case .loginButtonFooter:
            return 70
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
        case let .ghostThisAccount(value):
            return switchItem(VeilgramSettingsIcons.ghost, "Veilgram.GhostThisAccount", strings.Veilgram_GhostThisAccount, value, { arguments.updateGhostThisAccount($0) })
        case let .ghostOnline(value):
            return switchItem(VeilgramSettingsIcons.ghostOnline, "Veilgram.GhostOnline", strings.Veilgram_GhostOnline, value, { arguments.update(.ghostOnline, $0) })
        case let .ghostTyping(value):
            return switchItem(VeilgramSettingsIcons.ghostTyping, "Veilgram.GhostTyping", strings.Veilgram_GhostTyping, value, { arguments.update(.ghostTyping, $0) })
        case let .ghostRead(value):
            return switchItem(VeilgramSettingsIcons.ghostRead, "Veilgram.GhostRead", strings.Veilgram_GhostRead, value, { arguments.update(.ghostRead, $0) })
        case let .ghostStories(value):
            return switchItem(VeilgramSettingsIcons.ghostStories, "Veilgram.GhostStories", strings.Veilgram_GhostStories, value, { arguments.update(.ghostStories, $0) })
        case let .readOnReply(value):
            return switchItem(VeilgramSettingsIcons.ghostRead, "Veilgram.ReadOnReply", strings.Veilgram_ReadOnReply, value, { arguments.update(.readOnReply, $0) })
        case let .ghostOfflineSend(value):
            return switchItem(VeilgramSettingsIcons.ghostOnline, "Veilgram.GhostOfflineSend", strings.Veilgram_GhostOfflineSend, value, { arguments.update(.ghostOfflineSend, $0) })
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
        case let .confirmLinks(value):
            return switchItem(VeilgramSettingsIcons.confirmSend, "Veilgram.ConfirmLinks", strings.Veilgram_ConfirmLinks, value, { arguments.update(.confirmLinks, $0) })
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
        case let .hideSponsored(value):
            return switchItem(VeilgramSettingsIcons.keywordFilter, "Veilgram.HideSponsored", strings.Veilgram_HideSponsored, value, { arguments.update(.hideSponsored, $0) })
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
        case let .hideUsername(value):
            return switchItem(VeilgramSettingsIcons.hidePhone, "Veilgram.HideUsername", strings.Veilgram_HideUsername, value, { arguments.update(.hideUsername, $0) })
        case let .hideChatListTime(value):
            return switchItem(VeilgramSettingsIcons.hideStories, "Veilgram.HideChatListTime", strings.Veilgram_HideChatListTime, value, { arguments.update(.hideChatListTime, $0) })
        case let .hideChatListPreviews(value):
            return switchItem(VeilgramSettingsIcons.hideStories, "Veilgram.HideChatListPreviews", strings.Veilgram_HideChatListPreviews, value, { arguments.update(.hideChatListPreviews, $0) })
        case .screenFooter:
            return footerItem("Veilgram.ScreenInfo", strings.Veilgram_ScreenInfo)
        case .bannerHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: veilgramLocalized(strings, "Veilgram.BannerHeader", strings.Veilgram_BannerHeader).uppercased(), sectionId: self.section)
        case .bannerColor:
            return ItemListDisclosureItem(presentationData: presentationData, systemStyle: .glass, title: veilgramLocalized(strings, "Veilgram.BannerColor", strings.Veilgram_BannerColor), label: "", sectionId: self.section, style: .blocks, action: {
                arguments.chooseBanner(.color)
            })
        case .bannerPhoto:
            return ItemListDisclosureItem(presentationData: presentationData, systemStyle: .glass, title: veilgramLocalized(strings, "Veilgram.BannerPhoto", strings.Veilgram_BannerPhoto), label: "", sectionId: self.section, style: .blocks, action: {
                arguments.chooseBanner(.photo)
            })
        case .bannerVideo:
            return ItemListDisclosureItem(presentationData: presentationData, systemStyle: .glass, title: veilgramLocalized(strings, "Veilgram.BannerVideo", strings.Veilgram_BannerVideo), label: "", sectionId: self.section, style: .blocks, action: {
                arguments.chooseBanner(.video)
            })
        case .bannerRemove:
            return ItemListActionItem(presentationData: presentationData, systemStyle: .glass, title: veilgramLocalized(strings, "Veilgram.BannerRemove", strings.Veilgram_BannerRemove), kind: .destructive, alignment: .natural, sectionId: self.section, style: .blocks, action: {
                arguments.removeBanner()
            })
        case .bannerFooter:
            return footerItem("Veilgram.BannerInfo", strings.Veilgram_BannerInfo)
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
        case let .localTranscription(value):
            return switchItem(VeilgramSettingsIcons.localTranscription, "Veilgram.LocalTranscription", strings.Veilgram_LocalTranscription, value, { arguments.update(.localTranscription, $0) })
        case let .localTranslation(value):
            return switchItem(VeilgramSettingsIcons.localTranslation, "Veilgram.LocalTranslation", strings.Veilgram_LocalTranslation, value, { arguments.update(.localTranslation, $0) })
        case let .quietHours(value):
            return switchItem(VeilgramSettingsIcons.quietHours, "Veilgram.QuietHours", strings.Veilgram_QuietHours, value, { arguments.update(.quietHours, $0) })
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
private func veilgramSettingsEntries(showCallsTab: Bool, accountPeerId: EnginePeer.Id) -> [VeilgramSettingsEntry] {
    var entries: [VeilgramSettingsEntry] = []

    entries.append(.ghost(VeilgramSettings.value(.ghost)))
    if VeilgramSettings.value(.ghost) {
        entries.append(.ghostThisAccount(VeilgramSettings.ghostEnabled(account: accountPeerId)))
        entries.append(.ghostOnline(VeilgramSettings.value(.ghostOnline)))
        entries.append(.ghostTyping(VeilgramSettings.value(.ghostTyping)))
        entries.append(.ghostRead(VeilgramSettings.value(.ghostRead)))
        entries.append(.ghostStories(VeilgramSettings.value(.ghostStories)))
        if VeilgramSettings.value(.ghostRead) {
            entries.append(.readOnReply(VeilgramSettings.value(.readOnReply)))
        }
        if VeilgramSettings.value(.ghostOnline) {
            entries.append(.ghostOfflineSend(VeilgramSettings.value(.ghostOfflineSend)))
        }
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
    entries.append(.hideSponsored(VeilgramSettings.value(.hideSponsored)))
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
    entries.append(.confirmLinks(VeilgramSettings.value(.confirmLinks)))
    entries.append(.confirmSendFooter)

    entries.append(.screenHeader)
    entries.append(.streamerMode(VeilgramSettings.value(.streamerMode)))
    entries.append(.hidePhone(VeilgramSettings.value(.hidePhone)))
    entries.append(.hideUsername(VeilgramSettings.value(.hideUsername)))
    entries.append(.hideChatListTime(VeilgramSettings.value(.hideChatListTime)))
    entries.append(.hideChatListPreviews(VeilgramSettings.value(.hideChatListPreviews)))
    entries.append(.screenFooter)

    entries.append(.bannerHeader)
    entries.append(.bannerColor)
    entries.append(.bannerPhoto)
    entries.append(.bannerVideo)
    if VeilgramSettings.profileBannerKind != nil {
        entries.append(.bannerRemove)
    }
    entries.append(.bannerFooter)

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
    entries.append(.localTranscription(VeilgramSettings.value(.localTranscription)))
    entries.append(.localTranslation(VeilgramSettings.value(.localTranslation)))
    entries.append(.quietHours(VeilgramSettings.value(.quietHours)))
    entries.append(.fastTransfers(VeilgramSettings.value(.fastTransfers)))
    entries.append(.fastTransfersFooter)

    entries.append(.loginButton(VeilgramSettings.value(.loginOpenTelegramButton)))
    entries.append(.loginButtonFooter)

    return entries
}

public func veilgramSettingsController(context: AccountContext) -> ViewController {
    var pushImpl: ((ViewController) -> Void)?
    var presentImpl: ((ViewController) -> Void)?
    var controllerViewImpl: (() -> UIView?)?
    let arguments = VeilgramSettingsControllerArguments(
        update: { key, value in
            VeilgramSettings.set(key, value)
        },
        updateGhostThisAccount: { value in
            VeilgramSettings.setGhostEnabled(value, account: context.account.peerId)
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
        },
        chooseBanner: { kind in
            switch kind {
            case .color:
                let presentationData = context.sharedContext.currentPresentationData.with { $0 }
                let strings = presentationData.strings
                let colors: [(String, UInt32)] = [
                    ("Veilgram.ColorBlack", 0x000000), ("Veilgram.ColorGray", 0x3A3A3C), ("Veilgram.ColorBlue", 0x007AFF),
                    ("Veilgram.ColorPurple", 0x5856D6), ("Veilgram.ColorPink", 0xFF2D55), ("Veilgram.ColorRed", 0xFF3B30),
                    ("Veilgram.ColorOrange", 0xFF9500), ("Veilgram.ColorGreen", 0x34C759), ("Veilgram.ColorTeal", 0x5AC8FA)
                ]
                let actionSheet = ActionSheetController(presentationData: presentationData)
                var items: [ActionSheetItem] = []
                for (key, color) in colors {
                    items.append(ActionSheetButtonItem(title: veilgramLocalized(strings, key, key), action: { [weak actionSheet] in
                        actionSheet?.dismissAnimated()
                        VeilgramSettings.setProfileBanner(kind: .color, color: color)
                    }))
                }
                actionSheet.setItemGroups([ActionSheetItemGroup(items: items), ActionSheetItemGroup(items: [
                    ActionSheetButtonItem(title: strings.Common_Cancel, color: .accent, font: .bold, action: { [weak actionSheet] in
                        actionSheet?.dismissAnimated()
                    })
                ])])
                presentImpl?(actionSheet)
            case .photo, .video:
                VeilgramBannerPicker.present(kind: kind, from: controllerViewImpl?())
            }
        },
        removeBanner: {
            VeilgramSettings.setProfileBanner(kind: nil)
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
        let listState = ItemListNodeState(presentationData: ItemListPresentationData(presentationData), entries: veilgramSettingsEntries(showCallsTab: showCallsTab, accountPeerId: context.account.peerId), style: .blocks, animateChanges: true)
        return (controllerState, (listState, arguments))
    }

    let controller = ItemListController(context: context, state: signal)
    pushImpl = { [weak controller] c in
        controller?.push(c)
    }
    presentImpl = { [weak controller] c in
        controller?.present(c, in: .window(.root))
    }
    controllerViewImpl = { [weak controller] in
        return controller?.view
    }
    return controller
}
