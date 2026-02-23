import GameplayKit

final class JumpingState: FighterState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is IdleState.Type, is AttackingState.Type,
             is HitStunState.Type, is KnockbackState.Type, is DefeatedState.Type:
            return true
        default:
            return false
        }
    }

    override func didEnter(from previousState: GKState?) {
        fighter.physics.jump()
        fighter.animation.play("jump")
    }

    override func handleInput(_ input: InputState) {
        // Air control
        if abs(input.moveX) > 0.2 {
            fighter.physics.velocity.dx = input.moveX * fighter.definition.walkSpeed * K.airControl
        }

        // Air attacks
        if input.lightPunch {
            fighter.startMove(MoveData.lightPunch(for: fighter.definition.id))
            stateMachine?.enter(AttackingState.self)
            return
        }
        if input.heavyKick {
            fighter.startMove(MoveData.heavyKick(for: fighter.definition.id))
            stateMachine?.enter(AttackingState.self)
            return
        }

        // Land
        if fighter.physics.isGrounded {
            stateMachine?.enter(IdleState.self)
        }
    }
}
