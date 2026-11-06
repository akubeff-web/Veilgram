import Foundation
import Postbox

/// Earlier versions of a message the other side edited, oldest first, each with the time it was
/// replaced. Kept by Veilgram; the server keeps no history of edits.
public final class VeilgramEditHistoryMessageAttribute: MessageAttribute {
    public struct Entry: Equatable {
        public let date: Int32
        public let text: String

        public init(date: Int32, text: String) {
            self.date = date
            self.text = text
        }
    }

    private static let maxEntries = 50

    public let entries: [Entry]

    public init(entries: [Entry]) {
        self.entries = entries
    }

    required public init(decoder: PostboxDecoder) {
        let dates = decoder.decodeInt32ArrayForKey("d")
        let texts = decoder.decodeStringArrayForKey("t")
        var entries: [Entry] = []
        for i in 0 ..< min(dates.count, texts.count) {
            entries.append(Entry(date: dates[i], text: texts[i]))
        }
        self.entries = entries
    }

    public func encode(_ encoder: PostboxEncoder) {
        encoder.encodeInt32Array(self.entries.map(\.date), forKey: "d")
        encoder.encodeStringArray(self.entries.map(\.text), forKey: "t")
    }

    func appending(_ entry: Entry) -> VeilgramEditHistoryMessageAttribute {
        var entries = self.entries
        entries.append(entry)
        if entries.count > VeilgramEditHistoryMessageAttribute.maxEntries {
            entries.removeFirst(entries.count - VeilgramEditHistoryMessageAttribute.maxEntries)
        }
        return VeilgramEditHistoryMessageAttribute(entries: entries)
    }
}

public extension Message {
    var veilgramEditHistory: [VeilgramEditHistoryMessageAttribute.Entry] {
        for attribute in self.attributes {
            if let attribute = attribute as? VeilgramEditHistoryMessageAttribute {
                return attribute.entries
            }
        }
        return []
    }
}

/// The attributes of a server copy of `previousMessage`: the server's own carry no history, so the
/// stored one is kept, and when the text changed on an incoming message the previous text is added.
func veilgramEditHistoryAttributes(previous previousMessage: Message, updatedText: String, attributes: [MessageAttribute]) -> [MessageAttribute] {
    let previousAttribute = previousMessage.attributes.first(where: { $0 is VeilgramEditHistoryMessageAttribute }) as? VeilgramEditHistoryMessageAttribute
    var updatedAttribute = previousAttribute
    if VeilgramSettings.editHistory, previousMessage.flags.contains(.Incoming), previousMessage.id.namespace == Namespaces.Message.Cloud, previousMessage.text != updatedText, !previousMessage.text.isEmpty {
        let timestamp = Int32(CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970)
        let entry = VeilgramEditHistoryMessageAttribute.Entry(date: timestamp, text: previousMessage.text)
        updatedAttribute = (updatedAttribute ?? VeilgramEditHistoryMessageAttribute(entries: [])).appending(entry)
    }
    guard let updatedAttribute else {
        return attributes
    }
    var result = attributes.filter { !($0 is VeilgramEditHistoryMessageAttribute) }
    result.append(updatedAttribute)
    return result
}
