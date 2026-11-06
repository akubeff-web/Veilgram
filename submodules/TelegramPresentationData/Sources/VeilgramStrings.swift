import Foundation

// Veilgram strings. English comes from Localizable.strings (the generated `Veilgram_*` getters).
// Telegram's server language packs do not have these keys, so Russian is kept here and used when the
// app language is Russian and the language pack does not translate the key itself.
private let veilgramRussianStrings: [String: String] = [
    "Veilgram.Title": "Veilgram",
    "Veilgram.OpenTelegram": "Открыть Telegram",
    "Veilgram.Ghost": "Режим призрака",
    "Veilgram.GhostOnline": "Скрывать «в сети»",
    "Veilgram.GhostTyping": "Не отправлять «печатает»",
    "Veilgram.GhostRead": "Не отправлять прочтение",
    "Veilgram.GhostStories": "Не отправлять просмотр историй",
    "Veilgram.GhostInfo": "Другие не видят, что вы в сети, печатаете или прочитали. После отправки сообщения вы сразу снова «не в сети», но время «был(а) в сети» обновится.",
    "Veilgram.AlwaysOnline": "Всегда в сети",
    "Veilgram.AlwaysOnlineInfo": "Пока Veilgram открыт или работает в фоне, вы видны в сети. Когда iOS усыпит приложение, статус «в сети» продержится ещё несколько минут. Включённая функция отменяет «Скрывать «в сети»».",
    "Veilgram.KeepDeleted": "Удалённые сообщения",
    "Veilgram.DeletedIcon": "Значок корзины у времени",
    "Veilgram.KeepDeletedInfo": "Сообщения, удалённые собеседником или админом, остаются в чате. Ваши собственные удаления работают как обычно.",
    "Veilgram.AutoArchive": "Автоархив и мьют новых чатов",
    "Veilgram.AutoArchiveGroups": "Включая группы и каналы",
    "Veilgram.AutoArchiveInfo": "Новые чаты от людей не из контактов сразу уходят в архив без звука. Если приложение закрыто, о самом первом сообщении придёт уведомление со звуком.",
    "Veilgram.Tabs": "Вкладки",
    "Veilgram.TabContacts": "Контакты",
    "Veilgram.TabCalls": "Звонки",
    "Veilgram.TabNews": "Новости",
    "Veilgram.LoginButton": "Кнопка «Открыть Telegram» при входе",
    "Veilgram.LoginButtonInfo": "Показывает на экране ввода кода кнопку, которая открывает официальный Telegram, куда приходит код.",
]

public func veilgramLocalized(_ strings: PresentationStrings, _ key: String, _ value: String) -> String {
    if strings.primaryComponent.dict[key] == nil, strings.primaryComponent.languageCode.lowercased().hasPrefix("ru"), let russian = veilgramRussianStrings[key] {
        return russian
    }
    return value
}
