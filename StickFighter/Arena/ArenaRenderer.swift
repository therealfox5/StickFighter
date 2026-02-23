import SpriteKit

/// Renders arena backgrounds programmatically.
final class ArenaRenderer {
    static func render(arena: ArenaID, size: CGSize) -> SKNode {
        let root = SKNode()

        switch arena {
        case .dojo:
            root.addChild(renderDojo(size: size))
        case .rooftop:
            root.addChild(renderRooftop(size: size))
        case .pit:
            root.addChild(renderPit(size: size))
        case .skyTemple:
            root.addChild(renderSkyTemple(size: size))
        }

        // Ground line
        let ground = SKShapeNode(rectOf: CGSize(width: size.width, height: 4))
        ground.fillColor = .gray
        ground.strokeColor = .clear
        ground.position = CGPoint(x: size.width / 2, y: K.groundY - 2)
        ground.zPosition = K.ZPos.arenaDetail
        root.addChild(ground)

        return root
    }

    // MARK: - Dojo

    private static func renderDojo(size: CGSize) -> SKNode {
        let node = SKNode()

        // Background
        let bg = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        bg.fillColor = SKColor(hex: 0x1a1a2e)
        bg.strokeColor = .clear
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.zPosition = K.ZPos.background
        node.addChild(bg)

        // Wooden floor
        let floor = SKShapeNode(rectOf: CGSize(width: size.width, height: K.groundY))
        floor.fillColor = SKColor(hex: 0x5c3a21)
        floor.strokeColor = .clear
        floor.position = CGPoint(x: size.width / 2, y: K.groundY / 2)
        floor.zPosition = K.ZPos.arenaDetail
        node.addChild(floor)

        // Floor planks
        for i in 0..<15 {
            let x = CGFloat(i) * (size.width / 15)
            let plank = SKShapeNode(rectOf: CGSize(width: 2, height: K.groundY))
            plank.fillColor = SKColor(hex: 0x4a2e18)
            plank.strokeColor = .clear
            plank.position = CGPoint(x: x, y: K.groundY / 2)
            plank.zPosition = K.ZPos.arenaDetail + 0.1
            node.addChild(plank)
        }

        // Wall panels
        for i in 0..<4 {
            let x = CGFloat(i + 1) * (size.width / 5)
            let panel = SKShapeNode(rectOf: CGSize(width: size.width / 6, height: size.height * 0.5))
            panel.fillColor = SKColor(hex: 0x16213e)
            panel.strokeColor = SKColor(hex: 0x2a4080)
            panel.lineWidth = 2
            panel.position = CGPoint(x: x, y: size.height * 0.55)
            panel.zPosition = K.ZPos.arenaDetail
            node.addChild(panel)
        }

        // Lanterns
        for x in [size.width * 0.2, size.width * 0.8] {
            let lantern = SKShapeNode(rectOf: CGSize(width: 16, height: 24))
            lantern.fillColor = SKColor(hex: 0xff6600)
            lantern.strokeColor = .clear
            lantern.position = CGPoint(x: x, y: size.height * 0.75)
            lantern.zPosition = K.ZPos.arenaDetail

            let glow = SKShapeNode(circleOfRadius: 25)
            glow.fillColor = SKColor(red: 1.0, green: 0.4, blue: 0, alpha: 0.15)
            glow.strokeColor = .clear
            glow.position = lantern.position
            glow.zPosition = K.ZPos.arenaDetail

            node.addChild(glow)
            node.addChild(lantern)
        }

        return node
    }

    // MARK: - Rooftop

    private static func renderRooftop(size: CGSize) -> SKNode {
        let node = SKNode()

        // Night sky
        let bg = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        bg.fillColor = SKColor(hex: 0x0a0a1a)
        bg.strokeColor = .clear
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.zPosition = K.ZPos.background
        node.addChild(bg)

        // Stars
        for _ in 0..<50 {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.5...2))
            star.fillColor = .white
            star.strokeColor = .clear
            star.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: size.height * 0.4...size.height)
            )
            star.zPosition = K.ZPos.background + 0.1
            star.alpha = CGFloat.random(in: 0.3...1.0)
            node.addChild(star)
        }

        // Moon
        let moon = SKShapeNode(circleOfRadius: 30)
        moon.fillColor = SKColor(hex: 0xe0e0f0)
        moon.strokeColor = .clear
        moon.position = CGPoint(x: size.width * 0.8, y: size.height * 0.8)
        moon.zPosition = K.ZPos.background + 0.2
        node.addChild(moon)

        // Distant buildings
        for i in 0..<8 {
            let w = CGFloat.random(in: 60...120)
            let h = CGFloat.random(in: 100...300)
            let building = SKShapeNode(rectOf: CGSize(width: w, height: h))
            building.fillColor = SKColor(hex: 0x151530)
            building.strokeColor = .clear
            building.position = CGPoint(
                x: CGFloat(i) * (size.width / 7) + CGFloat.random(in: -20...20),
                y: K.groundY + h / 2
            )
            building.zPosition = K.ZPos.arenaDetail - 0.5
            node.addChild(building)

            // Windows
            for row in 0..<Int(h / 25) {
                for col in 0..<Int(w / 20) {
                    if CGFloat.random(in: 0...1) < 0.3 {
                        let window = SKShapeNode(rectOf: CGSize(width: 6, height: 8))
                        window.fillColor = SKColor(hex: 0xffff66, alpha: 0.6)
                        window.strokeColor = .clear
                        window.position = CGPoint(
                            x: building.position.x - w / 2 + CGFloat(col) * 20 + 12,
                            y: building.position.y - h / 2 + CGFloat(row) * 25 + 15
                        )
                        window.zPosition = K.ZPos.arenaDetail - 0.4
                        node.addChild(window)
                    }
                }
            }
        }

        // Rooftop floor
        let roof = SKShapeNode(rectOf: CGSize(width: size.width, height: K.groundY))
        roof.fillColor = SKColor(hex: 0x333344)
        roof.strokeColor = .clear
        roof.position = CGPoint(x: size.width / 2, y: K.groundY / 2)
        roof.zPosition = K.ZPos.arenaDetail
        node.addChild(roof)

        return node
    }

    // MARK: - The Pit

    private static func renderPit(size: CGSize) -> SKNode {
        let node = SKNode()

        // Dark underground bg
        let bg = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        bg.fillColor = SKColor(hex: 0x0d0d0d)
        bg.strokeColor = .clear
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.zPosition = K.ZPos.background
        node.addChild(bg)

        // Rock walls
        for side in [CGFloat(30), size.width - 30] {
            let wall = SKShapeNode(rectOf: CGSize(width: 60, height: size.height))
            wall.fillColor = SKColor(hex: 0x2a2a2a)
            wall.strokeColor = SKColor(hex: 0x3a3a3a)
            wall.lineWidth = 2
            wall.position = CGPoint(x: side, y: size.height / 2)
            wall.zPosition = K.ZPos.arenaDetail
            node.addChild(wall)
        }

        // Chains hanging from ceiling
        for i in 0..<6 {
            let x = CGFloat(i + 1) * (size.width / 7)
            let chainLen = CGFloat.random(in: 80...200)
            let chain = SKShapeNode(rectOf: CGSize(width: 3, height: chainLen))
            chain.fillColor = SKColor(hex: 0x666666)
            chain.strokeColor = .clear
            chain.position = CGPoint(x: x, y: size.height - chainLen / 2)
            chain.zPosition = K.ZPos.arenaDetail
            node.addChild(chain)
        }

        // Lava at bottom
        let lava = SKShapeNode(rectOf: CGSize(width: size.width - 120, height: 30))
        lava.fillColor = SKColor(hex: 0xff3300)
        lava.strokeColor = .clear
        lava.position = CGPoint(x: size.width / 2, y: 15)
        lava.zPosition = K.ZPos.arenaDetail

        let lavaGlow = SKShapeNode(rectOf: CGSize(width: size.width - 100, height: 60))
        lavaGlow.fillColor = SKColor(red: 1.0, green: 0.2, blue: 0, alpha: 0.1)
        lavaGlow.strokeColor = .clear
        lavaGlow.position = CGPoint(x: size.width / 2, y: 40)
        lavaGlow.zPosition = K.ZPos.arenaDetail

        node.addChild(lavaGlow)
        node.addChild(lava)

        // Stone floor
        let floor = SKShapeNode(rectOf: CGSize(width: size.width - 120, height: K.groundY - 20))
        floor.fillColor = SKColor(hex: 0x3d3d3d)
        floor.strokeColor = .clear
        floor.position = CGPoint(x: size.width / 2, y: (K.groundY - 20) / 2 + 25)
        floor.zPosition = K.ZPos.arenaDetail
        node.addChild(floor)

        return node
    }

    // MARK: - Sky Temple

    private static func renderSkyTemple(size: CGSize) -> SKNode {
        let node = SKNode()

        // Sky gradient (light blue)
        let bg = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        bg.fillColor = SKColor(hex: 0x87ceeb)
        bg.strokeColor = .clear
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.zPosition = K.ZPos.background
        node.addChild(bg)

        // Clouds
        for _ in 0..<8 {
            let cloud = SKShapeNode(ellipseOf: CGSize(
                width: CGFloat.random(in: 80...200),
                height: CGFloat.random(in: 30...60)
            ))
            cloud.fillColor = SKColor(white: 1.0, alpha: 0.7)
            cloud.strokeColor = .clear
            cloud.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: size.height * 0.5...size.height * 0.9)
            )
            cloud.zPosition = K.ZPos.background + 0.1

            let drift = SKAction.moveBy(x: CGFloat.random(in: -30...30), y: 0,
                                        duration: TimeInterval.random(in: 5...10))
            cloud.run(.repeatForever(.sequence([drift, drift.reversed()])))
            node.addChild(cloud)
        }

        // Temple pillars
        for i in 0..<5 {
            let x = CGFloat(i) * (size.width / 4)
            let pillar = SKShapeNode(rectOf: CGSize(width: 30, height: 200))
            pillar.fillColor = SKColor(hex: 0xd4c5a0)
            pillar.strokeColor = SKColor(hex: 0xbfb090)
            pillar.lineWidth = 2
            pillar.position = CGPoint(x: x + size.width * 0.05, y: K.groundY + 100)
            pillar.zPosition = K.ZPos.arenaDetail
            node.addChild(pillar)

            // Pillar cap
            let cap = SKShapeNode(rectOf: CGSize(width: 42, height: 12))
            cap.fillColor = SKColor(hex: 0xd4c5a0)
            cap.strokeColor = SKColor(hex: 0xbfb090)
            cap.position = CGPoint(x: pillar.position.x, y: K.groundY + 206)
            cap.zPosition = K.ZPos.arenaDetail
            node.addChild(cap)
        }

        // Temple floor (marble)
        let floor = SKShapeNode(rectOf: CGSize(width: size.width, height: K.groundY))
        floor.fillColor = SKColor(hex: 0xd4c5a0)
        floor.strokeColor = .clear
        floor.position = CGPoint(x: size.width / 2, y: K.groundY / 2)
        floor.zPosition = K.ZPos.arenaDetail
        node.addChild(floor)

        return node
    }
}
