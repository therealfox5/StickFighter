import GameplayKit

final class KnockbackState: FighterState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is IdleState.Type, is KnockdownState.Type,
             is DefeatedState.Type:
            return true
        default:
            return false
        }
    }

    override func didEnter(from previousState: GKState?) {
        fighter.animation.play("hitStun", forceRestart: true)
    }

    override func handleInput(_ input: InputState) {
        fighter.combat.update()

        if !fighter.health.isAlive {
            stateMachine?.enter(DefeatedState.self)
            return
        }

        // When landing from knockback
        if fighter.physics.isGrounded && fighter.physics.velocity.dy <= 0 {
            if fighter.combat.hitStunRemaining > 0 {
                stateMachine?.enter(KnockdownState.self)
            } else {
                stateMachine?.enter(IdleState.self)
            }
        }
    }
}
