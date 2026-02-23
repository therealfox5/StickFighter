import GameplayKit

final class HitStunState: FighterState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is IdleState.Type, is KnockbackState.Type,
             is DefeatedState.Type, is HitStunState.Type:
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

        if fighter.combat.hitStunRemaining <= 0 {
            fighter.combo.resetCombo()
            stateMachine?.enter(IdleState.self)
        }
    }
}
