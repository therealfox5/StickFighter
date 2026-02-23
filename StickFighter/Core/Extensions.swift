import CoreGraphics
import SpriteKit

extension CGPoint {
    func distance(to other: CGPoint) -> CGFloat {
        hypot(other.x - x, other.y - y)
    }

    static func lerp(_ a: CGPoint, _ b: CGPoint, t: CGFloat) -> CGPoint {
        CGPoint(x: a.x + (b.x - a.x) * t, y: a.y + (b.y - a.y) * t)
    }
}

extension CGFloat {
    static func lerp(_ a: CGFloat, _ b: CGFloat, t: CGFloat) -> CGFloat {
        a + (b - a) * t
    }

    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

extension CGVector {
    var length: CGFloat { hypot(dx, dy) }

    var normalized: CGVector {
        let len = length
        guard len > 0 else { return .zero }
        return CGVector(dx: dx / len, dy: dy / len)
    }
}

extension SKNode {
    func shake(intensity: CGFloat = 8, duration: TimeInterval = 0.3) {
        let count = Int(duration * 60)
        var actions: [SKAction] = []
        for i in 0..<count {
            let factor = CGFloat(count - i) / CGFloat(count)
            let dx = CGFloat.random(in: -intensity...intensity) * factor
            let dy = CGFloat.random(in: -intensity...intensity) * factor
            actions.append(SKAction.moveBy(x: dx, y: dy, duration: 1.0 / 60.0))
        }
        actions.append(SKAction.moveTo(x: position.x, duration: 0))
        actions.append(SKAction.moveTo(y: position.y, duration: 0))
        run(SKAction.sequence(actions), withKey: "shake")
    }
}

extension SKColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255.0,
            green: CGFloat((hex >> 8) & 0xFF) / 255.0,
            blue: CGFloat(hex & 0xFF) / 255.0,
            alpha: alpha
        )
    }
}

func angleLerp(_ a: CGFloat, _ b: CGFloat, t: CGFloat) -> CGFloat {
    var diff = b - a
    while diff > .pi { diff -= 2 * .pi }
    while diff < -.pi { diff += 2 * .pi }
    return a + diff * t
}
