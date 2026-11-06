import Foundation
import UIKit
import Display
import SwiftSignalKit
import TelegramPresentationData
import ItemListUI
import AccountContext
import UndoUI

private final class VeilgramRowsControllerArguments {
    let copy: (String) -> Void

    init(copy: @escaping (String) -> Void) {
        self.copy = copy
    }
}

private struct VeilgramRowsEntry: ItemListNodeEntry {
    let index: Int32
    let label: String
    let text: String

    var section: ItemListSectionId {
        return 0
    }

    var stableId: Int32 {
        return self.index
    }

    static func <(lhs: VeilgramRowsEntry, rhs: VeilgramRowsEntry) -> Bool {
        return lhs.index < rhs.index
    }

    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let arguments = arguments as! VeilgramRowsControllerArguments
        let text = self.text
        return ItemListTextWithLabelItem(presentationData: presentationData, label: self.label, text: text, style: .blocks, enabledEntityTypes: [], multiline: true, sectionId: self.section, action: {
            arguments.copy(text)
        })
    }
}

/// A list of labelled values; tapping one copies its value. Used by the message details and the
/// edit history screens.
public func veilgramRowsController(context: AccountContext, title: String, rows: [(label: String, value: String)]) -> ViewController {
    var presentImpl: ((ViewController) -> Void)?
    let arguments = VeilgramRowsControllerArguments(copy: { text in
        UIPasteboard.general.string = text
        let presentationData = context.sharedContext.currentPresentationData.with { $0 }
        presentImpl?(UndoOverlayController(presentationData: presentationData, content: .copy(text: veilgramLocalized(presentationData.strings, "Veilgram.Copied", presentationData.strings.Veilgram_Copied)), elevatedLayout: false, action: { _ in
            return false
        }))
    })

    let entries = rows.enumerated().map { index, row in
        return VeilgramRowsEntry(index: Int32(index), label: row.label, text: row.value)
    }

    let signal = context.sharedContext.presentationData
    |> map { presentationData -> (ItemListControllerState, (ItemListNodeState, Any)) in
        let controllerState = ItemListControllerState(presentationData: ItemListPresentationData(presentationData), title: .text(title), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back))
        let listState = ItemListNodeState(presentationData: ItemListPresentationData(presentationData), entries: entries, style: .blocks, animateChanges: false)
        return (controllerState, (listState, arguments))
    }

    let controller = ItemListController(context: context, state: signal)
    presentImpl = { [weak controller] c in
        controller?.present(c, in: .current)
    }
    return controller
}
