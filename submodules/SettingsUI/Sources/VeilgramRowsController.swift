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
    let open: (Int32) -> Void

    init(copy: @escaping (String) -> Void, open: @escaping (Int32) -> Void) {
        self.copy = copy
        self.open = open
    }
}

private struct VeilgramRowsEntry: ItemListNodeEntry {
    let index: Int32
    let label: String
    let text: String
    let canOpen: Bool

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
        let index = self.index
        if self.canOpen {
            return ItemListTextWithLabelItem(presentationData: presentationData, label: self.label, text: text, style: .blocks, enabledEntityTypes: [], multiline: true, sectionId: self.section, action: {
                arguments.open(index)
            }, longTapAction: {
                arguments.copy(text)
            })
        }
        return ItemListTextWithLabelItem(presentationData: presentationData, label: self.label, text: text, style: .blocks, enabledEntityTypes: [], multiline: true, sectionId: self.section, action: {
            arguments.copy(text)
        })
    }
}

/// A list of labelled values; tapping one copies its value. Used by the message details and the
/// edit history screens.
public func veilgramRowsController(context: AccountContext, title: String, rows: [(label: String, value: String)]) -> ViewController {
    let openableRows = rows.map { row -> (label: String, value: String, open: ((ViewController) -> Void)?) in
        return (row.label, row.value, nil)
    }
    return veilgramRowsController(context: context, title: title, rows: openableRows)
}

/// The same with an action per row: a row that has one runs it on a tap and copies on a long press.
public func veilgramRowsController(context: AccountContext, title: String, rows: [(label: String, value: String, open: ((ViewController) -> Void)?)]) -> ViewController {
    var controllerRef: (() -> ViewController?)?
    var presentImpl: ((ViewController) -> Void)?
    let arguments = VeilgramRowsControllerArguments(copy: { text in
        UIPasteboard.general.string = text
        let presentationData = context.sharedContext.currentPresentationData.with { $0 }
        presentImpl?(UndoOverlayController(presentationData: presentationData, content: .copy(text: veilgramLocalized(presentationData.strings, "Veilgram.Copied", presentationData.strings.Veilgram_Copied)), elevatedLayout: false, action: { _ in
            return false
        }))
    }, open: { index in
        guard Int(index) < rows.count, let open = rows[Int(index)].open, let controller = controllerRef?() else {
            return
        }
        open(controller)
    })

    let entries = rows.enumerated().map { index, row in
        return VeilgramRowsEntry(index: Int32(index), label: row.label, text: row.value, canOpen: row.open != nil)
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
    controllerRef = { [weak controller] in
        return controller
    }
    return controller
}
