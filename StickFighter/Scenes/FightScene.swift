import SpriteKit
import GameplayKit

final class FightScene: SKScene {
    // Coordinator
    weak var coordinator: GameCoordinator?

    // Fighters
    private var fighter1: Fighter!
    private var fighter2: Fighter!

    // Systems
    private let inputManager = InputManager()
    private var aiBrain: AIBrain?
    private var hud: HUDOverlay!

    // Round state
    private var roundPhase: RoundPhase = .intro
    private var roundTimer: Int = K.roundTime
    private var frameCount: Int = 0
    private var introTimer: Int = 0
    private var koTimer: Int = 0

    // Camera
    private var cameraNode: SKCameraNode!

    override func didMove(to view: SKView) {
        backgroundColor = .black
        physicsWorld.gravity = .zero  // We handle gravity manually

        setupCamera()
        setupArena()
        setupFighters()
        setupHUD()
        setupInputLayout()

        startIntro()
    }

    // MARK: - Setup

    private func setupCamera() {
        cameraNode = SKCameraNode()
        cameraNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(cameraNode)
        camera = cameraNode
    }

    private func setupArena() {
        let arenaID = coordinator?.selectedArena ?? .dojo
        let arenaNode = ArenaRenderer.render(arena: arenaID, size: size)
        addChild(arenaNode)
    }

    private func setupFighters() {
        let p1Char = coordinator?.player1Character ?? .kai
        let p2Char = coordinator?.player2Character ?? .kai

        fighter1 = Fighter(playerSlot: .player1, characterID: p1Char)
        fighter2 = Fighter(playerSlot: .player2, characterID: p2Char)

        fighter1.opponent = fighter2
        fighter2.opponent = fighter1

        let p1Start = CGPoint(x: size.width * 0.3, y: K.groundY)
        let p2Start = CGPoint(x: size.width * 0.7, y: K.groundY)

        fighter1.reset(at: p1Start, facing: .right)
        fighter2.reset(at: p2Start, facing: .left)

        addChild(fighter1.node)
        addChild(fighter2.node)

        // AI setup
        let mode = coordinator?.gameMode ?? .singlePlayer
        if mode == .singlePlayer {
            let difficulty = coordinator?.aiDifficulty ?? .medium
            aiBrain = AIBrain(difficulty: difficulty)
        }
        inputManager.isTwoPlayer = (mode == .twoPlayer)
    }

    private func setupHUD() {
        hud = HUDOverlay(sceneSize: size)
        hud.setNames(
            p1: fighter1.definition.displayName,
            p2: fighter2.definition.displayName
        )
        cameraNode.addChild(hud)
        // Offset HUD to center of camera view
        hud.position = CGPoint(x: -size.width / 2, y: -size.height / 2)
    }

    private func setupInputLayout() {
        let layout = hud.controlLayout()
        // Adjust for HUD being offset within camera
        inputManager.p1JoystickCenter = layout.joystickCenter
        inputManager.p1JoystickRadius = layout.joystickRadius
        inputManager.p1Buttons = layout.buttons

        // For 2-player, mirror controls on right side
        if inputManager.isTwoPlayer {
            inputManager.p2JoystickCenter = CGPoint(x: size.width - layout.joystickCenter.x,
                                                      y: layout.joystickCenter.y)
            inputManager.p2JoystickRadius = layout.joystickRadius
            // Mirror button positions
            inputManager.p2Buttons = layout.buttons.map { btn in
                let mirrorX = size.width - btn.rect.origin.x - btn.rect.width
                return (CGRect(x: mirrorX, y: btn.rect.origin.y,
                              width: btn.rect.width, height: btn.rect.height), btn.action)
            }
        }
    }

    // MARK: - Round Flow

    private func startIntro() {
        roundPhase = .intro
        introTimer = 120  // 2 seconds

        showAnnouncement("ROUND \(coordinator?.currentRound ?? 1)", duration: 1.0) { [weak self] in
            self?.showAnnouncement("FIGHT!", duration: 0.5) { [weak self] in
                self?.roundPhase = .fighting
            }
        }
    }

    func startNewRound() {
        let p1Start = CGPoint(x: size.width * 0.3, y: K.groundY)
        let p2Start = CGPoint(x: size.width * 0.7, y: K.groundY)
        fighter1.reset(at: p1Start, facing: .right)
        fighter2.reset(at: p2Start, facing: .left)
        roundTimer = K.roundTime
        frameCount = 0
        koTimer = 0

        startIntro()
    }

    private func showAnnouncement(_ text: String, duration: TimeInterval, completion: (() -> Void)? = nil) {
        let label = SKLabelNode(text: text)
        label.fontName = "Helvetica-Bold"
        label.fontSize = 60
        label.fontColor = .white
        label.position = CGPoint(x: 0, y: 0)
        label.zPosition = K.ZPos.announcement
        label.setScale(0.1)
        cameraNode.addChild(label)

        let scaleUp = SKAction.scale(to: 1.0, duration: 0.2)
        scaleUp.timingMode = .easeOut
        let wait = SKAction.wait(forDuration: duration)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let remove = SKAction.removeFromParent()

        label.run(SKAction.sequence([scaleUp, wait, fadeOut, remove])) {
            completion?()
        }
    }

    // MARK: - Game Loop

    override func update(_ currentTime: TimeInterval) {
        guard roundPhase == .fighting || roundPhase == .ko else { return }

        frameCount += 1

        if roundPhase == .fighting {
            // Process input
            var p1Input = inputManager.player1Input
            var p2Input: InputState

            if let ai = aiBrain {
                p2Input = ai.generateInput(for: fighter2, opponent: fighter1, frameCount: frameCount)
            } else {
                p2Input = inputManager.player2Input
            }

            // Update fighters
            fighter1.update(input: p1Input, deltaTime: 1.0 / 60.0)
            fighter2.update(input: p2Input, deltaTime: 1.0 / 60.0)

            // Clear one-shot inputs
            inputManager.player1Input.clearActions()
            inputManager.player2Input.clearActions()

            // Collision detection (hitbox vs hurtbox)
            checkHitboxes()

            // Push fighters apart if overlapping
            resolveFighterOverlap()

            // Update timer
            if frameCount % 60 == 0 {
                roundTimer -= 1
            }

            // Check win conditions
            checkWinConditions()

            // Update camera
            updateCamera()
        } else if roundPhase == .ko {
            koTimer += 1
            fighter1.update(input: InputState(), deltaTime: 1.0 / 60.0)
            fighter2.update(input: InputState(), deltaTime: 1.0 / 60.0)

            if koTimer >= K.koSlowdownFrames * 2 {
                endRound()
            }
        }

        // Update HUD
        hud.update(
            p1Health: fighter1.health.healthPercent,
            p2Health: fighter2.health.healthPercent,
            timer: roundTimer,
            p1Rounds: coordinator?.player1RoundWins ?? 0,
            p2Rounds: coordinator?.player2RoundWins ?? 0,
            p1Combo: fighter1.combo.comboCount,
            p2Combo: fighter2.combo.comboCount
        )
    }

    // MARK: - Hit Detection

    private func checkHitboxes() {
        checkAttack(attacker: fighter1, defender: fighter2)
        checkAttack(attacker: fighter2, defender: fighter1)
    }

    private func checkAttack(attacker: Fighter, defender: Fighter) {
        guard let move = attacker.currentMove,
              move.isActive(at: attacker.moveFrame),
              !attacker.hasHitThisMove,
              !defender.combat.isInvincible else { return }

        // Calculate hitbox position
        let facingSign = attacker.facing.rawValue
        let hitboxCenter = CGPoint(
            x: attacker.physics.position.x + move.hitboxOffset.x * facingSign,
            y: attacker.physics.position.y + move.hitboxOffset.y
        )
        let hitboxRect = CGRect(
            x: hitboxCenter.x - move.hitboxSize.width / 2,
            y: hitboxCenter.y - move.hitboxSize.height / 2,
            width: move.hitboxSize.width,
            height: move.hitboxSize.height
        )

        // Simple hurtbox (fighter center rect)
        let hurtboxRect = CGRect(
            x: defender.physics.position.x - 20,
            y: defender.physics.position.y,
            width: 40,
            height: 100
        )

        if hitboxRect.intersects(hurtboxRect) {
            // Hit!
            attacker.hasHitThisMove = true
            let isBlocking = defender.combat.isBlocking

            let result = DamageCalculator.calculate(
                move: move,
                comboCount: attacker.combo.comboCount,
                isBlocking: isBlocking,
                attackerFacing: attacker.facing
            )

            defender.takeDamage(result: result)

            if !result.wasBlocked {
                attacker.combo.registerHit(attackType: move.attackType, currentFrame: frameCount)
            }

            // Effects
            let hitPos = CGPoint(x: hitboxCenter.x, y: hitboxCenter.y)
            HitEffect.spawnHitSpark(at: hitPos, in: self, blocked: result.wasBlocked)

            if !result.wasBlocked && result.damage > 8 {
                HitEffect.screenShake(scene: self, intensity: result.damage * 0.5)
                HitEffect.hitPause(scene: self, duration: 0.04)
            }

            if attacker.combo.comboCount >= 2 {
                HitEffect.showComboCounter(attacker.combo.comboCount,
                                          at: defender.physics.position, in: self)
            }
        }
    }

    private func resolveFighterOverlap() {
        let minDist: CGFloat = 50
        let dx = fighter2.physics.position.x - fighter1.physics.position.x
        let dist = abs(dx)

        if dist < minDist {
            let push = (minDist - dist) / 2
            let sign: CGFloat = dx >= 0 ? 1 : -1
            fighter1.physics.position.x -= push * sign
            fighter2.physics.position.x += push * sign
        }
    }

    // MARK: - Win Conditions

    private func checkWinConditions() {
        if !fighter1.health.isAlive {
            triggerKO(winner: fighter2, loser: fighter1, winnerSlot: 2)
        } else if !fighter2.health.isAlive {
            triggerKO(winner: fighter1, loser: fighter2, winnerSlot: 1)
        } else if roundTimer <= 0 {
            // Time out — player with more health wins
            let winner = fighter1.health.healthPercent >= fighter2.health.healthPercent ? 1 : 2
            if winner == 1 {
                triggerKO(winner: fighter1, loser: fighter2, winnerSlot: 1)
            } else {
                triggerKO(winner: fighter2, loser: fighter1, winnerSlot: 2)
            }
        }
    }

    private func triggerKO(winner: Fighter, loser: Fighter, winnerSlot: Int) {
        guard roundPhase == .fighting else { return }
        roundPhase = .ko
        koTimer = 0

        winner.stateMachine.enter(VictoryState.self)
        loser.stateMachine.enter(DefeatedState.self)

        showAnnouncement("K.O.!", duration: 1.5)

        // Camera zoom on KO
        let zoomIn = SKAction.scale(to: 0.7, duration: 0.5)
        zoomIn.timingMode = .easeOut
        let wait = SKAction.wait(forDuration: 1.0)
        let zoomOut = SKAction.scale(to: 1.0, duration: 0.5)
        cameraNode.run(SKAction.sequence([zoomIn, wait, zoomOut]))

        // Focus camera on winner
        let focusX = (winner.physics.position.x + loser.physics.position.x) / 2
        let focusY = size.height / 2
        let moveCamera = SKAction.move(to: CGPoint(x: focusX, y: focusY), duration: 0.5)
        cameraNode.run(moveCamera)

        HitEffect.screenShake(scene: self, intensity: 12)
    }

    private func endRound() {
        let winner = !fighter1.health.isAlive ? 2 : 1
        coordinator?.roundEnded(winner: winner)
    }

    // MARK: - Camera

    private func updateCamera() {
        let midX = (fighter1.physics.position.x + fighter2.physics.position.x) / 2
        let dist = abs(fighter1.physics.position.x - fighter2.physics.position.x)
        let zoom = max(0.8, min(1.0, 500 / max(dist, 1)))

        let targetPos = CGPoint(x: midX, y: size.height / 2)
        cameraNode.position.x += (targetPos.x - cameraNode.position.x) * 0.1
        cameraNode.position.y += (targetPos.y - cameraNode.position.y) * 0.1

        let currentScale = cameraNode.xScale
        let newScale = currentScale + (1.0 / zoom - currentScale) * 0.05
        cameraNode.setScale(newScale)
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            // Convert to HUD space
            let hudLocation = CGPoint(x: location.x, y: location.y)
            inputManager.touchBegan(touch, at: hudLocation)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let hudLocation = CGPoint(x: location.x, y: location.y)
            inputManager.touchMoved(touch, at: hudLocation)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            inputManager.touchEnded(touch)
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            inputManager.touchEnded(touch)
        }
    }
}
