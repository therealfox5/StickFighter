import SpriteKit
import GameplayKit

/// Main fighter entity — owns all components.
final class Fighter {
    let playerSlot: PlayerSlot
    let definition: FighterDefinition
    let node: SKNode

    // Components
    let renderer: StickFigureRenderer
    let animation: AnimationComponent
    let physics: PhysicsComponent
    let health: HealthComponent
    let combat: CombatComponent
    let inputBuffer: InputBuffer
    let combo: ComboDetector

    // State machine
    let stateMachine: GKStateMachine

    // Current move being executed
    var currentMove: MoveData?
    var moveFrame: Int = 0
    var hasHitThisMove: Bool = false

    // Opponent reference
    weak var opponent: Fighter?

    var facing: FighterFacing {
        get { physics.facing }
        set {
            physics.facing = newValue
            node.xScale = newValue == .right ? definition.scale : -definition.scale
        }
    }

    init(playerSlot: PlayerSlot, characterID: CharacterID) {
        self.playerSlot = playerSlot
        self.definition = FighterCatalog.definition(for: characterID)
        self.node = SKNode()

        self.renderer = StickFigureRenderer(color: definition.color)
        self.animation = AnimationComponent()
        self.physics = PhysicsComponent()
        self.health = HealthComponent(maxHealth: definition.maxHealth)
        self.combat = CombatComponent()
        self.inputBuffer = InputBuffer()
        self.combo = ComboDetector()

        // Configure
        animation.characterID = characterID
        physics.walkSpeed = definition.walkSpeed
        physics.jumpForce = definition.jumpForce
        node.setScale(definition.scale)
        node.zPosition = K.ZPos.fighter

        // Add renderer to node
        node.addChild(renderer.rootNode)

        // Setup state machine
        let states: [GKState] = [
            IdleState(fighter: self),
            WalkingState(fighter: self),
            JumpingState(fighter: self),
            AttackingState(fighter: self),
            BlockingState(fighter: self),
            HitStunState(fighter: self),
            KnockbackState(fighter: self),
            KnockdownState(fighter: self),
            VictoryState(fighter: self),
            DefeatedState(fighter: self),
        ]
        self.stateMachine = GKStateMachine(states: states)
        stateMachine.enter(IdleState.self)

        animation.play("idle")
    }

    func update(input: InputState, deltaTime: TimeInterval) {
        // Update input buffer
        let adjustedDir = adjustDirectionForFacing(input.direction)
        inputBuffer.push(adjustedDir)

        // Update state machine (it reads input)
        (stateMachine.currentState as? FighterState)?.handleInput(input)

        // Physics
        physics.update()
        node.position = physics.position

        // Auto-face opponent
        if let opp = opponent,
           !(stateMachine.currentState is AttackingState),
           !(stateMachine.currentState is HitStunState),
           !(stateMachine.currentState is KnockbackState) {
            if opp.physics.position.x > physics.position.x {
                facing = .right
            } else if opp.physics.position.x < physics.position.x {
                facing = .left
            }
        }

        // Animation
        animation.update()
        renderer.applyPose(animation.currentPose)

        // Update move frame
        if currentMove != nil {
            moveFrame += 1
        }
    }

    func startMove(_ move: MoveData) {
        currentMove = move
        moveFrame = 0
        hasHitThisMove = false
        animation.play(move.animationClip, forceRestart: true)
    }

    func endMove() {
        currentMove = nil
        moveFrame = 0
    }

    func takeDamage(result: DamageResult) {
        health.takeDamage(result.damage)

        if result.wasBlocked {
            renderer.flashHit()
            combat.blockStunRemaining = result.blockStun
            stateMachine.enter(BlockingState.self)
        } else {
            renderer.flashHit()
            combat.hitStunRemaining = result.hitStun

            if result.knockback.dy > 50 {
                physics.applyKnockback(dx: result.knockback.dx, dy: result.knockback.dy)
                stateMachine.enter(KnockbackState.self)
            } else {
                physics.applyKnockback(dx: result.knockback.dx, dy: result.knockback.dy)
                stateMachine.enter(HitStunState.self)
            }
        }
    }

    func reset(at position: CGPoint, facing: FighterFacing) {
        health.reset()
        physics.position = position
        physics.velocity = .zero
        physics.isGrounded = true
        self.facing = facing
        node.position = position
        currentMove = nil
        moveFrame = 0
        hasHitThisMove = false
        combo.resetCombo()
        combat.reset()
        inputBuffer.clear()
        stateMachine.enter(IdleState.self)
        animation.play("idle", forceRestart: true)
    }

    /// Adjust input direction based on facing (so "forward" is always toward opponent).
    private func adjustDirectionForFacing(_ dir: InputDirection) -> InputDirection {
        if facing == .right { return dir }
        switch dir {
        case .forward: return .backward
        case .backward: return .forward
        case .downForward: return .downBackward
        case .downBackward: return .downForward
        case .upForward: return .upBackward
        case .upBackward: return .upForward
        default: return dir
        }
    }
}
