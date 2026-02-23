import CoreGraphics
import GameplayKit

enum AIMode {
    case aggressive
    case defensive
    case neutral
}

/// AI controller that generates InputState for a CPU-controlled fighter.
final class AIBrain {
    let difficulty: AIDifficulty
    private var mode: AIMode = .neutral
    private var decisionTimer: Int = 0
    private var currentAction: FighterAction = .idle
    private var actionDuration: Int = 0

    // Tuning
    private var reactionDelay: Int
    private var accuracy: CGFloat
    private var aggressionBias: CGFloat

    init(difficulty: AIDifficulty) {
        self.difficulty = difficulty
        self.reactionDelay = difficulty.reactionDelay
        self.accuracy = difficulty.accuracy
        self.aggressionBias = difficulty == .hard ? 0.6 : difficulty == .medium ? 0.4 : 0.2
    }

    func generateInput(for fighter: Fighter, opponent: Fighter, frameCount: Int) -> InputState {
        var input = InputState()
        decisionTimer += 1

        // Only make decisions at reaction intervals
        guard decisionTimer >= reactionDelay else {
            return applyCurrentAction(input: &input, fighter: fighter, opponent: opponent)
        }
        decisionTimer = 0

        let distance = abs(opponent.physics.position.x - fighter.physics.position.x)
        let healthRatio = fighter.health.healthPercent
        let oppHealthRatio = opponent.health.healthPercent

        // Choose AI mode
        updateMode(healthRatio: healthRatio, oppHealthRatio: oppHealthRatio, distance: distance)

        // Make decision based on mode and situation
        let roll = CGFloat.random(in: 0...1)

        switch mode {
        case .aggressive:
            currentAction = aggressiveDecision(distance: distance, roll: roll, opponent: opponent)
        case .defensive:
            currentAction = defensiveDecision(distance: distance, roll: roll, opponent: opponent)
        case .neutral:
            currentAction = neutralDecision(distance: distance, roll: roll, opponent: opponent)
        }

        actionDuration = Int.random(in: 10...30)

        return applyCurrentAction(input: &input, fighter: fighter, opponent: opponent)
    }

    private func updateMode(healthRatio: CGFloat, oppHealthRatio: CGFloat, distance: CGFloat) {
        if healthRatio < 0.3 {
            mode = CGFloat.random(in: 0...1) < 0.6 ? .defensive : .aggressive
        } else if oppHealthRatio < 0.3 {
            mode = .aggressive
        } else if distance > 300 {
            mode = CGFloat.random(in: 0...1) < aggressionBias ? .aggressive : .neutral
        } else {
            let r = CGFloat.random(in: 0...1)
            if r < aggressionBias { mode = .aggressive }
            else if r < aggressionBias + 0.3 { mode = .neutral }
            else { mode = .defensive }
        }
    }

    private func aggressiveDecision(distance: CGFloat, roll: CGFloat, opponent: Fighter) -> FighterAction {
        if distance > 200 {
            return .walkForward
        }
        if distance < 80 {
            if roll < accuracy * 0.4 { return .heavyPunch }
            if roll < accuracy * 0.6 { return .lightPunch }
            if roll < accuracy * 0.8 { return .lightKick }
            return .heavyKick
        }
        // Mid range
        if roll < accuracy * 0.3 { return .lightPunch }
        if roll < accuracy * 0.5 { return .walkForward }
        if roll < accuracy * 0.7 { return .lightKick }
        if roll < accuracy * 0.85 { return .special }
        return .walkForward
    }

    private func defensiveDecision(distance: CGFloat, roll: CGFloat, opponent: Fighter) -> FighterAction {
        let oppAttacking = opponent.stateMachine.currentState is AttackingState

        if oppAttacking && roll < accuracy {
            return .block
        }
        if distance < 120 {
            if roll < 0.4 { return .walkBackward }
            if roll < 0.6 { return .block }
            return .lightPunch  // poke
        }
        if distance < 250 {
            return roll < 0.5 ? .walkBackward : .block
        }
        return .idle
    }

    private func neutralDecision(distance: CGFloat, roll: CGFloat, opponent: Fighter) -> FighterAction {
        if distance > 300 {
            return .walkForward
        }
        if distance < 100 {
            if roll < 0.3 { return .lightPunch }
            if roll < 0.5 { return .walkBackward }
            if roll < 0.7 { return .block }
            return .lightKick
        }
        // Mid range
        if roll < 0.25 { return .walkForward }
        if roll < 0.5 { return .idle }
        if roll < 0.7 { return .walkBackward }
        return .lightPunch
    }

    private func applyCurrentAction(input: inout InputState, fighter: Fighter, opponent: Fighter) -> InputState {
        let toOpponent: CGFloat = opponent.physics.position.x > fighter.physics.position.x ? 1 : -1

        switch currentAction {
        case .walkForward:
            input.moveX = toOpponent
        case .walkBackward:
            input.moveX = -toOpponent
        case .jump:
            input.moveY = 1
        case .lightPunch:
            input.lightPunch = true
            currentAction = .idle // one-shot
        case .lightKick:
            input.lightKick = true
            currentAction = .idle
        case .heavyPunch:
            input.heavyPunch = true
            currentAction = .idle
        case .heavyKick:
            input.heavyKick = true
            currentAction = .idle
        case .special:
            input.special = true
            // Feed quarter-circle into buffer for special detection
            fighter.inputBuffer.push(.down)
            fighter.inputBuffer.push(.downForward)
            fighter.inputBuffer.push(.forward)
            currentAction = .idle
        case .block:
            input.block = true
        default:
            break
        }

        actionDuration -= 1
        if actionDuration <= 0 { currentAction = .idle }

        return input
    }
}
