import GameplayKit

final class IdleState: FighterState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass != DefeatedState.self || !fighter.health.isAlive
    }

    override func didEnter(from previousState: GKState?) {
        fighter.physics.stopHorizontal()
        fighter.animation.play("idle")
        fighter.endMove()
    }

    override func handleInput(_ input: InputState) {
        // Check attacks first
        if input.special {
            let specialInput = ComboDetector.detectSpecialInput(buffer: fighter.inputBuffer)
            if specialInput != .none {
                fighter.startMove(MoveData.special(for: fighter.definition.id))
                stateMachine?.enter(AttackingState.self)
                return
            }
        }
        if input.heavyKick {
            fighter.startMove(MoveData.heavyKick(for: fighter.definition.id))
            stateMachine?.enter(AttackingState.self)
            return
        }
        if input.heavyPunch {
            fighter.startMove(MoveData.heavyPunch(for: fighter.definition.id))
            stateMachine?.enter(AttackingState.self)
            return
        }
        if input.lightKick {
            fighter.startMove(MoveData.lightKick(for: fighter.definition.id))
            stateMachine?.enter(AttackingState.self)
            return
        }
        if input.lightPunch {
            fighter.startMove(MoveData.lightPunch(for: fighter.definition.id))
            stateMachine?.enter(AttackingState.self)
            return
        }

        if input.block {
            stateMachine?.enter(BlockingState.self)
            return
        }

        if input.moveY > 0.5 {
            stateMachine?.enter(JumpingState.self)
            return
        }

        if abs(input.moveX) > 0.2 {
            stateMachine?.enter(WalkingState.self)
            return
        }
    }
}
