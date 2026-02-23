import GameplayKit

final class VictoryState: FighterState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is IdleState.Type
    }

    override func didEnter(from previousState: GKState?) {
        fighter.physics.stopHorizontal()
        fighter.animation.play("victory", forceRestart: true)
    }

    override func handleInput(_ input: InputState) {
        // No input during victory
    }
}
