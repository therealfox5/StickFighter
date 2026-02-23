import GameplayKit

final class AttackingState: FighterState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        switch stateClass {
        case is IdleState.Type, is HitStunState.Type,
             is KnockbackState.Type, is DefeatedState.Type,
             is AttackingState.Type: // for combo chains
            return true
        default:
            return false
        }
    }

    override func didEnter(from previousState: GKState?) {
        // Move already set by the state that initiated the attack
    }

    override func handleInput(_ input: InputState) {
        guard let move = fighter.currentMove else {
            stateMachine?.enter(IdleState.self)
            return
        }

        // Check if move is complete
        if fighter.moveFrame >= move.totalFrames {
            fighter.endMove()
            if fighter.physics.isGrounded {
                stateMachine?.enter(IdleState.self)
            } else {
                stateMachine?.enter(JumpingState.self)
            }
            return
        }

        // Check cancel window for combo chains
        if move.canCancel(at: fighter.moveFrame) && fighter.hasHitThisMove {
            if input.heavyKick && fighter.combo.canChainInto(attackType: .heavyKick) {
                fighter.startMove(MoveData.heavyKick(for: fighter.definition.id))
                return
            }
            if input.heavyPunch && fighter.combo.canChainInto(attackType: .heavyPunch) {
                fighter.startMove(MoveData.heavyPunch(for: fighter.definition.id))
                return
            }
            if input.lightKick && fighter.combo.canChainInto(attackType: .lightKick) {
                fighter.startMove(MoveData.lightKick(for: fighter.definition.id))
                return
            }
        }
    }

    override func willExit(to nextState: GKState) {
        if !(nextState is AttackingState) {
            fighter.endMove()
        }
    }
}
