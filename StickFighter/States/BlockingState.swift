import GameplayKit

final class BlockingState: FighterState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is IdleState.Type, is HitStunState.Type,
             is KnockbackState.Type, is DefeatedState.Type:
            return true
        default:
            return false
        }
    }

    override func didEnter(from previousState: GKState?) {
        fighter.combat.isBlocking = true
        fighter.animation.play("block")
        fighter.physics.stopHorizontal()
    }

    override func handleInput(_ input: InputState) {
        fighter.combat.update()

        // In block stun, can't release block
        if fighter.combat.isInBlockStun { return }

        // Release block
        if !input.block {
            stateMachine?.enter(IdleState.self)
        }
    }

    override func willExit(to nextState: GKState) {
        fighter.combat.isBlocking = false
    }
}
