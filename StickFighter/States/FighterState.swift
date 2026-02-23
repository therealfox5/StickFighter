import GameplayKit

/// Base class for all fighter states.
class FighterState: GKState {
    unowned let fighter: Fighter

    init(fighter: Fighter) {
        self.fighter = fighter
        super.init()
    }

    func handleInput(_ input: InputState) {
        // Override in subclasses
    }
}
