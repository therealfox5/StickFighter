import GameplayKit

final class KnockdownState: FighterState {
    private var framesOnGround: Int = 0
    private let getUpFrames: Int = 40

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is IdleState.Type, is DefeatedState.Type:
            return true
        default:
            return false
        }
    }

    override func didEnter(from previousState: GKState?) {
        framesOnGround = 0
        fighter.physics.stopHorizontal()
        fighter.animation.play("knockdown", forceRestart: true)
        fighter.combat.invincibilityFrames = getUpFrames
    }

    override func handleInput(_ input: InputState) {
        framesOnGround += 1

        if !fighter.health.isAlive {
            stateMachine?.enter(DefeatedState.self)
            return
        }

        if framesOnGround >= getUpFrames {
            stateMachine?.enter(IdleState.self)
        }
    }
}
