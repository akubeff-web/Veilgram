import Foundation
import UIKit
import AsyncDisplayKit
import Display
import TelegramPresentationData
import GlassBackgroundComponent
import ComponentFlow

/// Ghost mode: an eye and the number of messages the server still counts as unread. Tapping it
/// sends the read receipt for this chat only.
final class VeilgramGhostReadPillNode: ASDisplayNode {
    static let height: CGFloat = 32.0

    private let backgroundView: GlassBackgroundView
    private let iconView: UIImageView
    private let label: UILabel

    private var theme: PresentationTheme
    private var preferClearGlass: Bool
    private var count: Int32 = 0

    var tapped: (() -> Void)?

    init(theme: PresentationTheme, preferClearGlass: Bool) {
        self.theme = theme
        self.preferClearGlass = preferClearGlass

        self.backgroundView = GlassBackgroundView()
        self.iconView = UIImageView()
        self.label = UILabel()
        self.label.font = Font.with(size: 14.0, weight: .medium, traits: [.monospacedNumbers])

        super.init()

        self.view.addSubview(self.backgroundView)
        self.backgroundView.contentView.addSubview(self.iconView)
        self.backgroundView.contentView.addSubview(self.label)
        self.backgroundView.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapGesture)))

        self.updateColors()
    }

    @objc private func tapGesture() {
        self.tapped?()
    }

    func updateTheme(theme: PresentationTheme, preferClearGlass: Bool) {
        if self.theme !== theme || self.preferClearGlass != preferClearGlass {
            self.theme = theme
            self.preferClearGlass = preferClearGlass
            self.updateColors()
            let _ = self.updateLayout()
        }
    }

    private func updateColors() {
        let color = self.theme.chat.inputPanel.panelControlColor
        self.iconView.image = veilgramCachedIcon(.eye, size: CGSize(width: 18.0, height: 18.0), color: color)
        self.label.textColor = color
    }

    func update(count: Int32) -> CGSize {
        self.count = count
        return self.updateLayout()
    }

    private func updateLayout() -> CGSize {
        self.label.text = "\(self.count)"
        let labelSize = self.label.sizeThatFits(CGSize(width: 200.0, height: VeilgramGhostReadPillNode.height))
        let iconSize = CGSize(width: 18.0, height: 18.0)
        let size = CGSize(width: 10.0 + iconSize.width + 5.0 + ceil(labelSize.width) + 12.0, height: VeilgramGhostReadPillNode.height)

        self.backgroundView.frame = CGRect(origin: CGPoint(), size: size)
        self.backgroundView.update(size: size, cornerRadius: size.height * 0.5, isDark: self.theme.overallDarkAppearance, tintColor: .init(kind: self.preferClearGlass ? .clear : .panel), isInteractive: true, transition: .immediate)
        self.iconView.frame = CGRect(origin: CGPoint(x: 10.0, y: floor((size.height - iconSize.height) / 2.0)), size: iconSize)
        self.label.frame = CGRect(origin: CGPoint(x: 10.0 + iconSize.width + 5.0, y: floor((size.height - ceil(labelSize.height)) / 2.0)), size: CGSize(width: ceil(labelSize.width), height: ceil(labelSize.height)))
        return size
    }
}
