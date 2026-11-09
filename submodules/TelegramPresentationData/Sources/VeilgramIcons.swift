import Foundation
import UIKit
import Display

/// Stroke icons from Lucide (https://lucide.dev, ISC license), drawn from their SVG source:
/// a 24×24 view box, stroke width 2, round caps and joins.
public enum VeilgramIcon: String {
    case ghost
    case venetianMask
    case eye
    case arrowUpToLine
    case chartColumn
    case download
    case filter
    case history
    case info
    case eyeOff
    case trash
    case archive
    case bellOff
    case panelBottom
    case send
    case wifi
    case wifiOff
    case penOff
    case checkCheck
    case circleDashed
    case users
    case user
    case phone
    case newspaper

    fileprivate var elements: [VeilgramIconElement] {
        switch self {
        case .ghost:
            return [
                .path("M15 10v1"),
                .path("M7.528 20.472a1.6 1.6 0 012.277 0l1.057 1.056a1.6 1.6 0 002.276 0l1.057-1.056a1.6 1.6 0 012.277 0l1.114 1.114a1.4 1.4 0 002.414-1V10a8 8 0 00-16 0v10.586a1.4 1.4 0 002.414 1z"),
                .path("M9 10v1")
            ]
        case .venetianMask:
            return [
                .path("M18 11c-1.5 0-2.5.5-3 2"),
                .path("M4 6a2 2 0 0 0-2 2v4a5 5 0 0 0 5 5 8 8 0 0 1 5 2 8 8 0 0 1 5-2 5 5 0 0 0 5-5V8a2 2 0 0 0-2-2h-3a8 8 0 0 0-5 2 8 8 0 0 0-5-2z"),
                .path("M6 11c1.5 0 2.5.5 3 2")
            ]
        case .history:
            return [
                .path("M3 12a9 9 0 1 0 9-9 9.75 9.75 0 0 0-6.74 2.74L3 8"),
                .path("M3 3v5h5"),
                .path("M12 7v5l4 2")
            ]
        case .info:
            return [
                .circle(cx: 12.0, cy: 12.0, r: 10.0),
                .path("M12 16v-4"),
                .path("M12 8h.01")
            ]
        case .filter:
            return [
                .path("M10 20a1 1 0 0 0 .553.895l2 1A1 1 0 0 0 14 21v-7a2 2 0 0 1 .517-1.341L21.74 4.67A1 1 0 0 0 21 3H3a1 1 0 0 0-.742 1.67l7.225 7.989A2 2 0 0 1 10 14z")
            ]
        case .download:
            return [
                .path("M12 15V3"),
                .path("M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"),
                .path("m7 10 5 5 5-5")
            ]
        case .arrowUpToLine:
            return [
                .path("M5 3h14"),
                .path("m18 13-6-6-6 6"),
                .path("M12 7v14")
            ]
        case .chartColumn:
            return [
                .path("M18 20V10"),
                .path("M12 20V4"),
                .path("M6 20v-6")
            ]
        case .eye:
            return [
                .path("M2.062 12.348a1 1 0 0 1 0-.696 10.75 10.75 0 0 1 19.876 0 1 1 0 0 1 0 .696 10.75 10.75 0 0 1-19.876 0"),
                .circle(cx: 12.0, cy: 12.0, r: 3.0)
            ]
        case .eyeOff:
            return [
                .path("M10.733 5.076a10.744 10.744 0 0 1 11.205 6.575 1 1 0 0 1 0 .696 10.747 10.747 0 0 1-1.444 2.49"),
                .path("M14.084 14.158a3 3 0 0 1-4.242-4.242"),
                .path("M17.479 17.499a10.75 10.75 0 0 1-15.417-5.151 1 1 0 0 1 0-.696 10.75 10.75 0 0 1 4.446-5.143"),
                .path("m2 2 20 20")
            ]
        case .trash:
            return [
                .path("M10 11v6"),
                .path("M14 11v6"),
                .path("M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6"),
                .path("M3 6h18"),
                .path("M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2")
            ]
        case .archive:
            return [
                .rect(x: 2.0, y: 3.0, width: 20.0, height: 5.0, rx: 1.0),
                .path("M4 8v11a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8"),
                .path("M10 12h4")
            ]
        case .bellOff:
            return [
                .path("M10.268 21a2 2 0 0 0 3.464 0"),
                .path("M17 17H4a1 1 0 0 1-.74-1.673C4.59 13.956 6 12.499 6 8a6 6 0 0 1 .258-1.742"),
                .path("m2 2 20 20"),
                .path("M8.668 3.01A6 6 0 0 1 18 8c0 2.687.77 4.653 1.707 6.05")
            ]
        case .panelBottom:
            return [
                .rect(x: 3.0, y: 3.0, width: 18.0, height: 18.0, rx: 2.0),
                .path("M3 15h18")
            ]
        case .send:
            return [
                .path("M14.536 21.686a.5.5 0 0 0 .937-.024l6.5-19a.496.496 0 0 0-.635-.635l-19 6.5a.5.5 0 0 0-.024.937l7.93 3.18a2 2 0 0 1 1.112 1.11z"),
                .path("m21.854 2.147-10.94 10.939")
            ]
        case .wifi:
            return [
                .path("M12 20h.01"),
                .path("M2 8.82a15 15 0 0 1 20 0"),
                .path("M5 12.859a10 10 0 0 1 14 0"),
                .path("M8.5 16.429a5 5 0 0 1 7 0")
            ]
        case .wifiOff:
            return [
                .path("M12 20h.01"),
                .path("M8.5 16.429a5 5 0 0 1 7 0"),
                .path("M5 12.859a10 10 0 0 1 5.17-2.69"),
                .path("M19 12.859a10 10 0 0 0-2.007-1.523"),
                .path("M2 8.82a15 15 0 0 1 4.177-2.643"),
                .path("M22 8.82a15 15 0 0 0-11.288-3.764"),
                .path("m2 2 20 20")
            ]
        case .penOff:
            return [
                .path("m10 10-6.157 6.162a2 2 0 0 0-.5.833l-1.322 4.36a.5.5 0 0 0 .622.624l4.358-1.323a2 2 0 0 0 .83-.5L14 13.982"),
                .path("m12.829 7.172 4.359-4.346a1 1 0 1 1 3.986 3.986l-4.353 4.353"),
                .path("m2 2 20 20")
            ]
        case .checkCheck:
            return [
                .path("M18 6 7 17l-5-5"),
                .path("m22 10-7.5 7.5L13 16")
            ]
        case .circleDashed:
            return [
                .path("M10.1 2.182a10 10 0 0 1 3.8 0"),
                .path("M13.9 21.818a10 10 0 0 1-3.8 0"),
                .path("M17.609 3.721a10 10 0 0 1 2.69 2.7"),
                .path("M2.182 13.9a10 10 0 0 1 0-3.8"),
                .path("M20.279 17.609a10 10 0 0 1-2.7 2.69"),
                .path("M21.818 10.1a10 10 0 0 1 0 3.8"),
                .path("M3.721 6.391a10 10 0 0 1 2.7-2.69"),
                .path("M6.391 20.279a10 10 0 0 1-2.69-2.7")
            ]
        case .users:
            return [
                .path("M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"),
                .path("M16 3.128a4 4 0 0 1 0 7.744"),
                .path("M22 21v-2a4 4 0 0 0-3-3.87"),
                .circle(cx: 9.0, cy: 7.0, r: 4.0)
            ]
        case .user:
            return [
                .path("M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"),
                .circle(cx: 12.0, cy: 7.0, r: 4.0)
            ]
        case .phone:
            return [
                .path("M13.832 16.568a1 1 0 0 0 1.213-.303l.355-.465A2 2 0 0 1 17 15h3a2 2 0 0 1 2 2v3a2 2 0 0 1-2 2A18 18 0 0 1 2 4a2 2 0 0 1 2-2h3a2 2 0 0 1 2 2v3a2 2 0 0 1-.8 1.6l-.468.351a1 1 0 0 0-.292 1.233 14 14 0 0 0 6.392 6.384")
            ]
        case .newspaper:
            return [
                .path("M15 18h-5"),
                .path("M18 14h-8"),
                .path("M4 22h16a2 2 0 0 0 2-2V4a2 2 0 0 0-2-2H8a2 2 0 0 0-2 2v16a2 2 0 0 1-4 0v-9a2 2 0 0 1 2-2h2"),
                .rect(x: 10.0, y: 6.0, width: 8.0, height: 4.0, rx: 1.0)
            ]
        }
    }
}

private enum VeilgramIconElement {
    case path(String)
    case rect(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, rx: CGFloat)
    case circle(cx: CGFloat, cy: CGFloat, r: CGFloat)

    var cgPath: CGPath {
        switch self {
        case let .path(data):
            return veilgramPathFromSvgData(data)
        case let .rect(x, y, width, height, rx):
            return CGPath(roundedRect: CGRect(x: x, y: y, width: width, height: height), cornerWidth: rx, cornerHeight: rx, transform: nil)
        case let .circle(cx, cy, r):
            return CGPath(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2.0, height: r * 2.0), transform: nil)
        }
    }
}

/// Strokes the icon into `rect` of a y-down context (as given by `generateImage(_:rotatedContext:)`).
/// `lineWidth` is in view box units, so 2.0 is Lucide's own stroke width at any size.
public func drawVeilgramIcon(_ icon: VeilgramIcon, context: CGContext, rect: CGRect, color: UIColor, lineWidth: CGFloat = 2.0) {
    let scale = min(rect.width, rect.height) / 24.0
    context.saveGState()
    context.translateBy(x: rect.minX + (rect.width - 24.0 * scale) * 0.5, y: rect.minY + (rect.height - 24.0 * scale) * 0.5)
    context.scaleBy(x: scale, y: scale)
    context.setStrokeColor(color.cgColor)
    context.setLineWidth(lineWidth)
    context.setLineCap(.round)
    context.setLineJoin(.round)
    for element in icon.elements {
        context.addPath(element.cgPath)
    }
    context.strokePath()
    context.restoreGState()
}

public func generateVeilgramIcon(_ icon: VeilgramIcon, size: CGSize, color: UIColor, lineWidth: CGFloat = 2.0) -> UIImage? {
    return generateImage(size, rotatedContext: { size, context in
        context.clear(CGRect(origin: CGPoint(), size: size))
        drawVeilgramIcon(icon, context: context, rect: CGRect(origin: CGPoint(), size: size), color: color, lineWidth: lineWidth)
    })
}

private let veilgramIconCache = NSCache<NSString, UIImage>()

/// Same as `generateVeilgramIcon`, cached by icon, size and color.
public func veilgramCachedIcon(_ icon: VeilgramIcon, size: CGSize, color: UIColor) -> UIImage? {
    let key = "\(icon.rawValue)-\(size.width)x\(size.height)-\(color.argb)" as NSString
    if let image = veilgramIconCache.object(forKey: key) {
        return image
    }
    guard let image = generateVeilgramIcon(icon, size: size, color: color) else {
        return nil
    }
    veilgramIconCache.setObject(image, forKey: key)
    return image
}

/// A settings row icon: white glyph on a rounded colored tile, the size of the other settings icons.
public func generateVeilgramSettingsIcon(_ icon: VeilgramIcon, backgroundColor: UIColor) -> UIImage? {
    return generateImage(CGSize(width: 30.0, height: 30.0), rotatedContext: { size, context in
        let bounds = CGRect(origin: CGPoint(), size: size)
        context.clear(bounds)
        context.addPath(CGPath(roundedRect: bounds, cornerWidth: 8.0, cornerHeight: 8.0, transform: nil))
        context.setFillColor(backgroundColor.cgColor)
        context.fillPath()
        drawVeilgramIcon(icon, context: context, rect: bounds.insetBy(dx: 6.0, dy: 6.0), color: .white)
    })
}

// MARK: - SVG path data

private struct VeilgramSvgScanner {
    let bytes: [UInt8]
    var index: Int = 0

    init(_ string: String) {
        self.bytes = Array(string.utf8)
    }

    var isAtEnd: Bool {
        return self.index >= self.bytes.count
    }

    mutating func skipSeparators() {
        while self.index < self.bytes.count {
            let c = self.bytes[self.index]
            if c == 32 || c == 44 || c == 9 || c == 10 || c == 13 {
                self.index += 1
            } else {
                break
            }
        }
    }

    /// The command letter at the current position, consumed, or nil when a number follows.
    mutating func readCommand() -> UInt8? {
        self.skipSeparators()
        guard self.index < self.bytes.count else {
            return nil
        }
        let c = self.bytes[self.index]
        let isLetter = (c >= 65 && c <= 90) || (c >= 97 && c <= 122)
        if isLetter && c != 101 && c != 69 {
            self.index += 1
            return c
        }
        return nil
    }

    mutating func readNumber() -> CGFloat? {
        self.skipSeparators()
        let start = self.index
        var seenDigit = false
        var seenPoint = false
        var seenExponent = false
        if self.index < self.bytes.count && (self.bytes[self.index] == 45 || self.bytes[self.index] == 43) {
            self.index += 1
        }
        while self.index < self.bytes.count {
            let c = self.bytes[self.index]
            if c >= 48 && c <= 57 {
                seenDigit = true
                self.index += 1
            } else if c == 46 && !seenPoint && !seenExponent {
                seenPoint = true
                self.index += 1
            } else if (c == 101 || c == 69) && seenDigit && !seenExponent {
                seenExponent = true
                self.index += 1
                if self.index < self.bytes.count && (self.bytes[self.index] == 45 || self.bytes[self.index] == 43) {
                    self.index += 1
                }
            } else {
                break
            }
        }
        if !seenDigit {
            self.index = start
            return nil
        }
        guard let string = String(bytes: self.bytes[start ..< self.index], encoding: .utf8), let value = Double(string) else {
            return nil
        }
        return CGFloat(value)
    }

    /// Arc flags are single characters and may be written without separators ("a1 1 0 012 0").
    mutating func readFlag() -> Bool? {
        self.skipSeparators()
        guard self.index < self.bytes.count else {
            return nil
        }
        let c = self.bytes[self.index]
        if c == 48 || c == 49 {
            self.index += 1
            return c == 49
        }
        return nil
    }
}

private func veilgramPathFromSvgData(_ data: String) -> CGPath {
    let path = CGMutablePath()
    var scanner = VeilgramSvgScanner(data)
    var current = CGPoint()
    var subpathStart = CGPoint()
    var lastCubicControl: CGPoint?
    var command: UInt8 = 0

    while true {
        if let nextCommand = scanner.readCommand() {
            command = nextCommand
        } else if scanner.isAtEnd || command == 0 || command == 90 || command == 122 {
            break
        }
        let isRelative = command >= 97
        let origin = isRelative ? current : CGPoint()
        var updatedCubicControl: CGPoint?

        switch command {
        case 77, 109: // M m
            guard let x = scanner.readNumber(), let y = scanner.readNumber() else {
                return path
            }
            current = CGPoint(x: origin.x + x, y: origin.y + y)
            subpathStart = current
            path.move(to: current)
            // Further coordinate pairs are implicit line commands.
            command = isRelative ? 108 : 76
        case 76, 108: // L l
            guard let x = scanner.readNumber(), let y = scanner.readNumber() else {
                return path
            }
            current = CGPoint(x: origin.x + x, y: origin.y + y)
            path.addLine(to: current)
        case 72, 104: // H h
            guard let x = scanner.readNumber() else {
                return path
            }
            current = CGPoint(x: origin.x + x, y: current.y)
            path.addLine(to: current)
        case 86, 118: // V v
            guard let y = scanner.readNumber() else {
                return path
            }
            current = CGPoint(x: current.x, y: origin.y + y)
            path.addLine(to: current)
        case 67, 99: // C c
            guard let x1 = scanner.readNumber(), let y1 = scanner.readNumber(), let x2 = scanner.readNumber(), let y2 = scanner.readNumber(), let x = scanner.readNumber(), let y = scanner.readNumber() else {
                return path
            }
            let control2 = CGPoint(x: origin.x + x2, y: origin.y + y2)
            current = CGPoint(x: origin.x + x, y: origin.y + y)
            path.addCurve(to: current, control1: CGPoint(x: origin.x + x1, y: origin.y + y1), control2: control2)
            updatedCubicControl = control2
        case 83, 115: // S s
            guard let x2 = scanner.readNumber(), let y2 = scanner.readNumber(), let x = scanner.readNumber(), let y = scanner.readNumber() else {
                return path
            }
            var control1 = current
            if let lastCubicControl {
                control1 = CGPoint(x: 2.0 * current.x - lastCubicControl.x, y: 2.0 * current.y - lastCubicControl.y)
            }
            let control2 = CGPoint(x: origin.x + x2, y: origin.y + y2)
            current = CGPoint(x: origin.x + x, y: origin.y + y)
            path.addCurve(to: current, control1: control1, control2: control2)
            updatedCubicControl = control2
        case 81, 113: // Q q
            guard let x1 = scanner.readNumber(), let y1 = scanner.readNumber(), let x = scanner.readNumber(), let y = scanner.readNumber() else {
                return path
            }
            current = CGPoint(x: origin.x + x, y: origin.y + y)
            path.addQuadCurve(to: current, control: CGPoint(x: origin.x + x1, y: origin.y + y1))
        case 65, 97: // A a
            guard let rx = scanner.readNumber(), let ry = scanner.readNumber(), let rotation = scanner.readNumber(), let largeArc = scanner.readFlag(), let sweep = scanner.readFlag(), let x = scanner.readNumber(), let y = scanner.readNumber() else {
                return path
            }
            let end = CGPoint(x: origin.x + x, y: origin.y + y)
            veilgramAddSvgArc(path: path, from: current, to: end, rx: rx, ry: ry, rotationDegrees: rotation, largeArc: largeArc, sweep: sweep)
            current = end
        case 90, 122: // Z z
            path.closeSubpath()
            current = subpathStart
        default:
            return path
        }
        lastCubicControl = updatedCubicControl
    }
    return path
}

/// Endpoint to center arc conversion, SVG 1.1 appendix F.6.5.
private func veilgramAddSvgArc(path: CGMutablePath, from start: CGPoint, to end: CGPoint, rx: CGFloat, ry: CGFloat, rotationDegrees: CGFloat, largeArc: Bool, sweep: Bool) {
    if start == end {
        return
    }
    var rx = abs(rx)
    var ry = abs(ry)
    if rx == 0.0 || ry == 0.0 {
        path.addLine(to: end)
        return
    }
    let phi = rotationDegrees * CGFloat.pi / 180.0
    let cosPhi = cos(phi)
    let sinPhi = sin(phi)

    let dx2 = (start.x - end.x) / 2.0
    let dy2 = (start.y - end.y) / 2.0
    let x1 = cosPhi * dx2 + sinPhi * dy2
    let y1 = -sinPhi * dx2 + cosPhi * dy2

    let lambda = (x1 * x1) / (rx * rx) + (y1 * y1) / (ry * ry)
    if lambda > 1.0 {
        rx *= sqrt(lambda)
        ry *= sqrt(lambda)
    }

    let numerator = rx * rx * ry * ry - rx * rx * y1 * y1 - ry * ry * x1 * x1
    let denominator = rx * rx * y1 * y1 + ry * ry * x1 * x1
    var coefficient = denominator == 0.0 ? 0.0 : sqrt(max(0.0, numerator / denominator))
    if largeArc == sweep {
        coefficient = -coefficient
    }
    let cxPrime = coefficient * rx * y1 / ry
    let cyPrime = -coefficient * ry * x1 / rx

    let cx = cosPhi * cxPrime - sinPhi * cyPrime + (start.x + end.x) / 2.0
    let cy = sinPhi * cxPrime + cosPhi * cyPrime + (start.y + end.y) / 2.0

    let ux = (x1 - cxPrime) / rx
    let uy = (y1 - cyPrime) / ry
    let vx = (-x1 - cxPrime) / rx
    let vy = (-y1 - cyPrime) / ry

    let startAngle = atan2(uy, ux)
    var delta = atan2(ux * vy - uy * vx, ux * vx + uy * vy)
    if !sweep && delta > 0.0 {
        delta -= 2.0 * CGFloat.pi
    } else if sweep && delta < 0.0 {
        delta += 2.0 * CGFloat.pi
    }

    // Unit circle -> ellipse with radii rx, ry, rotated by phi, centered at (cx, cy).
    let transform = CGAffineTransform(a: cosPhi * rx, b: sinPhi * rx, c: -sinPhi * ry, d: cosPhi * ry, tx: cx, ty: cy)
    path.addRelativeArc(center: CGPoint(), radius: 1.0, startAngle: startAngle, delta: delta, transform: transform)
}

/// Tile icons for the Veilgram rows in Settings, generated once.
public enum VeilgramSettingsIcons {
    public static let main = generateVeilgramSettingsIcon(.venetianMask, backgroundColor: UIColor(rgb: 0x3A3A3C))
    public static let ghost = generateVeilgramSettingsIcon(.ghost, backgroundColor: UIColor(rgb: 0x5856D6))
    public static let ghostOnline = generateVeilgramSettingsIcon(.wifiOff, backgroundColor: UIColor(rgb: 0x5856D6))
    public static let alwaysOnline = generateVeilgramSettingsIcon(.wifi, backgroundColor: UIColor(rgb: 0x34C759))
    public static let ghostTyping = generateVeilgramSettingsIcon(.penOff, backgroundColor: UIColor(rgb: 0x5856D6))
    public static let ghostRead = generateVeilgramSettingsIcon(.checkCheck, backgroundColor: UIColor(rgb: 0x5856D6))
    public static let ghostStories = generateVeilgramSettingsIcon(.circleDashed, backgroundColor: UIColor(rgb: 0x5856D6))
    public static let keepDeleted = generateVeilgramSettingsIcon(.eyeOff, backgroundColor: UIColor(rgb: 0xFF3B30))
    public static let deletedIcon = generateVeilgramSettingsIcon(.trash, backgroundColor: UIColor(rgb: 0xFF3B30))
    public static let editHistory = generateVeilgramSettingsIcon(.history, backgroundColor: UIColor(rgb: 0xFF3B30))
    public static let deletedLog = generateVeilgramSettingsIcon(.trash, backgroundColor: UIColor(rgb: 0x8E8E93))
    public static let confirmSend = generateVeilgramSettingsIcon(.send, backgroundColor: UIColor(rgb: 0x007AFF))
    public static let hideBlocked = generateVeilgramSettingsIcon(.eyeOff, backgroundColor: UIColor(rgb: 0xAF52DE))
    public static let keywordFilter = generateVeilgramSettingsIcon(.filter, backgroundColor: UIColor(rgb: 0xAF52DE))
    public static let hideStories = generateVeilgramSettingsIcon(.circleDashed, backgroundColor: UIColor(rgb: 0xFF9500))
    public static let unlockProtected = generateVeilgramSettingsIcon(.download, backgroundColor: UIColor(rgb: 0x34C759))
    public static let keepViewOnce = generateVeilgramSettingsIcon(.eye, backgroundColor: UIColor(rgb: 0x34C759))
    public static let streamerMode = generateVeilgramSettingsIcon(.venetianMask, backgroundColor: UIColor(rgb: 0xFF2D55))
    public static let hidePhone = generateVeilgramSettingsIcon(.phone, backgroundColor: UIColor(rgb: 0xFF2D55))
    public static let autoReply = generateVeilgramSettingsIcon(.send, backgroundColor: UIColor(rgb: 0x5AC8FA))
    public static let autoReplyContacts = generateVeilgramSettingsIcon(.users, backgroundColor: UIColor(rgb: 0x5AC8FA))
    public static let premiumItem = generateVeilgramSettingsIcon(.eyeOff, backgroundColor: UIColor(rgb: 0xAF52DE))
    public static let fastTransfers = generateVeilgramSettingsIcon(.download, backgroundColor: UIColor(rgb: 0x007AFF))
    public static let preloadMedia = generateVeilgramSettingsIcon(.download, backgroundColor: UIColor(rgb: 0xFF3B30))
    public static let preloadMediaGroups = generateVeilgramSettingsIcon(.users, backgroundColor: UIColor(rgb: 0xFF3B30))
    public static let localTranscription = generateVeilgramSettingsIcon(.penOff, backgroundColor: UIColor(rgb: 0x007AFF))
    public static let localTranslation = generateVeilgramSettingsIcon(.newspaper, backgroundColor: UIColor(rgb: 0x007AFF))
    public static let autoArchive = generateVeilgramSettingsIcon(.archive, backgroundColor: UIColor(rgb: 0xFF9500))
    public static let autoArchiveGroups = generateVeilgramSettingsIcon(.users, backgroundColor: UIColor(rgb: 0xFF9500))
    public static let tabContacts = generateVeilgramSettingsIcon(.user, backgroundColor: UIColor(rgb: 0x007AFF))
    public static let tabCalls = generateVeilgramSettingsIcon(.phone, backgroundColor: UIColor(rgb: 0x34C759))
    public static let tabNews = generateVeilgramSettingsIcon(.newspaper, backgroundColor: UIColor(rgb: 0xFF2D55))
    public static let loginButton = generateVeilgramSettingsIcon(.send, backgroundColor: UIColor(rgb: 0x2AABEE))
}
