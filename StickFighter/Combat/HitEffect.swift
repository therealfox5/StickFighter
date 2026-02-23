import SpriteKit

/// Visual and game-feel effects on hit.
final class HitEffect {
    /// Create hit spark particles at the given position.
    static func spawnHitSpark(at position: CGPoint, in scene: SKScene, blocked: Bool) {
        let count = blocked ? 4 : 8
        let color: SKColor = blocked ? .cyan : .yellow

        for _ in 0..<count {
            let spark = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...5))
            spark.fillColor = color
            spark.strokeColor = .clear
            spark.position = position
            spark.zPosition = K.ZPos.effect

            let angle = CGFloat.random(in: 0...(2 * .pi))
            let dist = CGFloat.random(in: 20...60)
            let dx = cos(angle) * dist
            let dy = sin(angle) * dist

            scene.addChild(spark)

            let move = SKAction.moveBy(x: dx, y: dy, duration: 0.2)
            let fade = SKAction.fadeOut(withDuration: 0.2)
            let scale = SKAction.scale(to: 0.1, duration: 0.2)
            let group = SKAction.group([move, fade, scale])
            spark.run(SKAction.sequence([group, .removeFromParent()]))
        }
    }

    /// Freeze both fighters briefly on hit (hit stop / hit pause).
    static func hitPause(scene: SKScene, duration: TimeInterval = 0.06) {
        scene.isPaused = true
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            scene.isPaused = false
        }
    }

    /// Screen shake effect.
    static func screenShake(scene: SKScene, intensity: CGFloat = 6) {
        scene.camera?.shake(intensity: intensity, duration: 0.2)
    }

    /// Spawn dust effect at feet.
    static func spawnDust(at position: CGPoint, in scene: SKScene) {
        for _ in 0..<5 {
            let dust = SKShapeNode(circleOfRadius: CGFloat.random(in: 3...7))
            dust.fillColor = SKColor(white: 0.7, alpha: 0.5)
            dust.strokeColor = .clear
            dust.position = position
            dust.zPosition = K.ZPos.effect

            let dx = CGFloat.random(in: -30...30)
            let dy = CGFloat.random(in: 5...25)

            scene.addChild(dust)

            let move = SKAction.moveBy(x: dx, y: dy, duration: 0.3)
            let fade = SKAction.fadeOut(withDuration: 0.3)
            dust.run(SKAction.sequence([SKAction.group([move, fade]), .removeFromParent()]))
        }
    }

    /// Combo counter display.
    static func showComboCounter(_ count: Int, at position: CGPoint, in scene: SKScene) {
        guard count >= 2 else { return }
        let label = SKLabelNode(text: "\(count) HIT!")
        label.fontName = "Helvetica-Bold"
        label.fontSize = 24
        label.fontColor = .yellow
        label.position = CGPoint(x: position.x, y: position.y + 80)
        label.zPosition = K.ZPos.effect
        scene.addChild(label)

        let moveUp = SKAction.moveBy(x: 0, y: 30, duration: 0.5)
        let fade = SKAction.fadeOut(withDuration: 0.5)
        label.run(SKAction.sequence([SKAction.group([moveUp, fade]), .removeFromParent()]))
    }
}
