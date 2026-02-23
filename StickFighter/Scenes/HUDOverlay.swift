import SpriteKit

/// HUD overlay showing health bars, timer, round indicators, and touch controls.
final class HUDOverlay: SKNode {
    private let sceneSize: CGSize

    // Health bars
    private let p1HealthBG = SKShapeNode()
    private let p1HealthBar = SKShapeNode()
    private let p2HealthBG = SKShapeNode()
    private let p2HealthBar = SKShapeNode()

    // Timer
    private let timerLabel = SKLabelNode()

    // Round indicators
    private let p1RoundDots: [SKShapeNode]
    private let p2RoundDots: [SKShapeNode]

    // Names
    private let p1NameLabel = SKLabelNode()
    private let p2NameLabel = SKLabelNode()

    // Combo counter
    private let p1ComboLabel = SKLabelNode()
    private let p2ComboLabel = SKLabelNode()

    // Touch controls (joystick + buttons)
    private let joystickBase = SKShapeNode(circleOfRadius: 60)
    private let joystickThumb = SKShapeNode(circleOfRadius: 25)
    private var buttons: [SKShapeNode] = []
    private var buttonLabels: [SKLabelNode] = []

    // P2 controls (for 2-player mode)
    private let p2JoystickBase = SKShapeNode(circleOfRadius: 60)
    private let p2JoystickThumb = SKShapeNode(circleOfRadius: 25)
    private var p2Buttons: [SKShapeNode] = []

    var isTwoPlayer: Bool = false

    // Health bar dimensions
    private let barWidth: CGFloat = 400
    private let barHeight: CGFloat = 20

    init(sceneSize: CGSize) {
        self.sceneSize = sceneSize
        self.p1RoundDots = (0..<2).map { _ in SKShapeNode(circleOfRadius: 6) }
        self.p2RoundDots = (0..<2).map { _ in SKShapeNode(circleOfRadius: 6) }
        super.init()
        self.zPosition = K.ZPos.hud
        setupHealthBars()
        setupTimer()
        setupRoundDots()
        setupNames()
        setupComboLabels()
        setupTouchControls()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setupHealthBars() {
        let topY = sceneSize.height - 30

        // P1 health bar (left, fills right to left)
        p1HealthBG.path = CGPath(rect: CGRect(x: 0, y: 0, width: barWidth, height: barHeight), transform: nil)
        p1HealthBG.fillColor = SKColor(hex: 0x333333)
        p1HealthBG.strokeColor = .white
        p1HealthBG.lineWidth = 2
        p1HealthBG.position = CGPoint(x: 40, y: topY)
        addChild(p1HealthBG)

        p1HealthBar.path = CGPath(rect: CGRect(x: 0, y: 0, width: barWidth, height: barHeight), transform: nil)
        p1HealthBar.fillColor = .green
        p1HealthBar.strokeColor = .clear
        p1HealthBar.position = CGPoint(x: 40, y: topY)
        addChild(p1HealthBar)

        // P2 health bar (right, fills left to right)
        let p2X = sceneSize.width - 40 - barWidth
        p2HealthBG.path = CGPath(rect: CGRect(x: 0, y: 0, width: barWidth, height: barHeight), transform: nil)
        p2HealthBG.fillColor = SKColor(hex: 0x333333)
        p2HealthBG.strokeColor = .white
        p2HealthBG.lineWidth = 2
        p2HealthBG.position = CGPoint(x: p2X, y: topY)
        addChild(p2HealthBG)

        p2HealthBar.path = CGPath(rect: CGRect(x: 0, y: 0, width: barWidth, height: barHeight), transform: nil)
        p2HealthBar.fillColor = .green
        p2HealthBar.strokeColor = .clear
        p2HealthBar.position = CGPoint(x: p2X, y: topY)
        addChild(p2HealthBar)
    }

    private func setupTimer() {
        timerLabel.fontName = "Helvetica-Bold"
        timerLabel.fontSize = 32
        timerLabel.fontColor = .white
        timerLabel.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height - 40)
        timerLabel.text = "99"
        addChild(timerLabel)
    }

    private func setupRoundDots() {
        for (i, dot) in p1RoundDots.enumerated() {
            dot.fillColor = SKColor(hex: 0x333333)
            dot.strokeColor = .yellow
            dot.lineWidth = 1.5
            dot.position = CGPoint(x: 50 + CGFloat(i) * 20, y: sceneSize.height - 60)
            addChild(dot)
        }
        for (i, dot) in p2RoundDots.enumerated() {
            dot.fillColor = SKColor(hex: 0x333333)
            dot.strokeColor = .yellow
            dot.lineWidth = 1.5
            dot.position = CGPoint(x: sceneSize.width - 50 - CGFloat(i) * 20, y: sceneSize.height - 60)
            addChild(dot)
        }
    }

    private func setupNames() {
        p1NameLabel.fontName = "Helvetica-Bold"
        p1NameLabel.fontSize = 16
        p1NameLabel.fontColor = .white
        p1NameLabel.horizontalAlignmentMode = .left
        p1NameLabel.position = CGPoint(x: 40, y: sceneSize.height - 68)
        addChild(p1NameLabel)

        p2NameLabel.fontName = "Helvetica-Bold"
        p2NameLabel.fontSize = 16
        p2NameLabel.fontColor = .white
        p2NameLabel.horizontalAlignmentMode = .right
        p2NameLabel.position = CGPoint(x: sceneSize.width - 40, y: sceneSize.height - 68)
        addChild(p2NameLabel)
    }

    private func setupComboLabels() {
        p1ComboLabel.fontName = "Helvetica-Bold"
        p1ComboLabel.fontSize = 20
        p1ComboLabel.fontColor = .yellow
        p1ComboLabel.position = CGPoint(x: 200, y: sceneSize.height - 90)
        p1ComboLabel.isHidden = true
        addChild(p1ComboLabel)

        p2ComboLabel.fontName = "Helvetica-Bold"
        p2ComboLabel.fontSize = 20
        p2ComboLabel.fontColor = .yellow
        p2ComboLabel.position = CGPoint(x: sceneSize.width - 200, y: sceneSize.height - 90)
        p2ComboLabel.isHidden = true
        addChild(p2ComboLabel)
    }

    private func setupTouchControls() {
        // P1 Joystick (bottom-left)
        let joyCenter = CGPoint(x: 120, y: 120)
        joystickBase.fillColor = SKColor(white: 0.3, alpha: 0.4)
        joystickBase.strokeColor = SKColor(white: 0.6, alpha: 0.6)
        joystickBase.lineWidth = 2
        joystickBase.position = joyCenter
        addChild(joystickBase)

        joystickThumb.fillColor = SKColor(white: 0.5, alpha: 0.6)
        joystickThumb.strokeColor = .white
        joystickThumb.lineWidth = 1.5
        joystickThumb.position = joyCenter
        addChild(joystickThumb)

        // P1 Buttons (bottom-right)
        let buttonDefs: [(label: String, action: FighterAction, offset: CGPoint)] = [
            ("LP", .lightPunch, CGPoint(x: -90, y: 50)),
            ("HP", .heavyPunch, CGPoint(x: -30, y: 80)),
            ("LK", .lightKick, CGPoint(x: -90, y: -10)),
            ("HK", .heavyKick, CGPoint(x: -30, y: 20)),
            ("SP", .special, CGPoint(x: 30, y: 50)),
            ("BL", .block, CGPoint(x: 30, y: -10)),
        ]

        let btnOrigin = CGPoint(x: sceneSize.width - 100, y: 100)
        for def in buttonDefs {
            let btn = SKShapeNode(circleOfRadius: 28)
            btn.fillColor = SKColor(white: 0.25, alpha: 0.5)
            btn.strokeColor = .white
            btn.lineWidth = 1.5
            btn.position = CGPoint(x: btnOrigin.x + def.offset.x, y: btnOrigin.y + def.offset.y)
            addChild(btn)
            buttons.append(btn)

            let lbl = SKLabelNode(text: def.label)
            lbl.fontName = "Helvetica-Bold"
            lbl.fontSize = 14
            lbl.fontColor = .white
            lbl.verticalAlignmentMode = .center
            lbl.position = btn.position
            addChild(lbl)
            buttonLabels.append(lbl)
        }
    }

    // MARK: - Update

    func update(p1Health: CGFloat, p2Health: CGFloat, timer: Int,
                p1Rounds: Int, p2Rounds: Int, p1Combo: Int, p2Combo: Int) {
        // Health bars
        let p1W = barWidth * max(0, p1Health)
        p1HealthBar.path = CGPath(rect: CGRect(x: 0, y: 0, width: p1W, height: barHeight), transform: nil)
        p1HealthBar.fillColor = healthColor(p1Health)

        let p2W = barWidth * max(0, p2Health)
        p2HealthBar.path = CGPath(rect: CGRect(x: barWidth - p2W, y: 0, width: p2W, height: barHeight), transform: nil)
        p2HealthBar.fillColor = healthColor(p2Health)

        // Timer
        timerLabel.text = "\(max(0, timer))"

        // Round dots
        for i in 0..<p1RoundDots.count {
            p1RoundDots[i].fillColor = i < p1Rounds ? .yellow : SKColor(hex: 0x333333)
        }
        for i in 0..<p2RoundDots.count {
            p2RoundDots[i].fillColor = i < p2Rounds ? .yellow : SKColor(hex: 0x333333)
        }

        // Combo
        if p1Combo >= 2 {
            p1ComboLabel.text = "\(p1Combo) HITS"
            p1ComboLabel.isHidden = false
        } else {
            p1ComboLabel.isHidden = true
        }
        if p2Combo >= 2 {
            p2ComboLabel.text = "\(p2Combo) HITS"
            p2ComboLabel.isHidden = false
        } else {
            p2ComboLabel.isHidden = true
        }
    }

    func setNames(p1: String, p2: String) {
        p1NameLabel.text = p1
        p2NameLabel.text = p2
    }

    /// Returns control layout info for InputManager.
    func controlLayout() -> (joystickCenter: CGPoint, joystickRadius: CGFloat,
                             buttons: [(rect: CGRect, action: FighterAction)]) {
        let buttonDefs: [(action: FighterAction, index: Int)] = [
            (.lightPunch, 0), (.heavyPunch, 1),
            (.lightKick, 2), (.heavyKick, 3),
            (.special, 4), (.block, 5),
        ]

        let btnRects: [(rect: CGRect, action: FighterAction)] = buttonDefs.compactMap { def in
            guard def.index < buttons.count else { return nil }
            let btn = buttons[def.index]
            let r: CGFloat = 28
            return (CGRect(x: btn.position.x - r, y: btn.position.y - r,
                          width: r * 2, height: r * 2), def.action)
        }

        return (joystickBase.position, 60, btnRects)
    }

    private func healthColor(_ percent: CGFloat) -> SKColor {
        if percent > 0.5 { return .green }
        if percent > 0.25 { return .yellow }
        return .red
    }
}
