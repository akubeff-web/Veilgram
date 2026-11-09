import Foundation
import UIKit
import AVFoundation
import TelegramCore

/// Veilgram: the own profile's header picture, a color, a photo or a looping muted video, as set in
/// Veilgram settings. Drawn over Telegram's own header background, on this device only.
final class VeilgramProfileBannerView: UIView {
    private let imageView = UIImageView()
    private var playerLayer: AVPlayerLayer?
    private var player: AVQueuePlayer?
    private var looper: AVPlayerLooper?
    private var currentKey: String?

    static var currentKey: String? {
        guard let kind = VeilgramSettings.profileBannerKind else {
            return nil
        }
        switch kind {
        case .color:
            return "color-\(VeilgramSettings.profileBannerColor)"
        case .photo, .video:
            guard let url = VeilgramSettings.profileBannerFileURL(kind: kind), FileManager.default.fileExists(atPath: url.path) else {
                return nil
            }
            let modified = (try? FileManager.default.attributesOfItem(atPath: url.path)[.modificationDate] as? Date)?.timeIntervalSince1970 ?? 0
            return "\(kind.rawValue)-\(modified)"
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        self.isUserInteractionEnabled = false
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.clipsToBounds = true
        self.addSubview(self.imageView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update() {
        let key = VeilgramProfileBannerView.currentKey
        if key == self.currentKey {
            return
        }
        self.currentKey = key
        self.player?.pause()
        self.playerLayer?.removeFromSuperlayer()
        self.playerLayer = nil
        self.player = nil
        self.looper = nil
        self.imageView.image = nil
        self.backgroundColor = nil

        guard key != nil, let kind = VeilgramSettings.profileBannerKind else {
            return
        }
        switch kind {
        case .color:
            let rgb = VeilgramSettings.profileBannerColor
            self.backgroundColor = UIColor(red: CGFloat((rgb >> 16) & 0xff) / 255.0, green: CGFloat((rgb >> 8) & 0xff) / 255.0, blue: CGFloat(rgb & 0xff) / 255.0, alpha: 1.0)
        case .photo:
            if let url = VeilgramSettings.profileBannerFileURL(kind: .photo) {
                self.imageView.image = UIImage(contentsOfFile: url.path)
            }
        case .video:
            if let url = VeilgramSettings.profileBannerFileURL(kind: .video) {
                let item = AVPlayerItem(url: url)
                let player = AVQueuePlayer()
                player.isMuted = true
                player.preventsDisplaySleepDuringVideoPlayback = false
                self.looper = AVPlayerLooper(player: player, templateItem: item)
                let playerLayer = AVPlayerLayer(player: player)
                playerLayer.videoGravity = .resizeAspectFill
                self.layer.addSublayer(playerLayer)
                self.playerLayer = playerLayer
                self.player = player
                player.play()
            }
        }
        self.setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.frame = self.bounds
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.playerLayer?.frame = self.bounds
        CATransaction.commit()
    }
}
