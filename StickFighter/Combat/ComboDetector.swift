import Foundation

/// Detects combo chains and special move inputs from the input buffer.
final class ComboDetector {
    private(set) var comboCount: Int = 0
    private var lastHitFrame: Int = 0
    private let comboDropThreshold: Int = 45  // frames before combo resets

    /// Light chains: LP -> LK -> HP -> HK
    private let chainOrder: [AttackType] = [.lightPunch, .lightKick, .heavyPunch, .heavyKick]
    private var lastAttackInChain: AttackType?

    func registerHit(attackType: AttackType, currentFrame: Int) {
        if currentFrame - lastHitFrame > comboDropThreshold {
            resetCombo()
        }
        comboCount += 1
        lastHitFrame = currentFrame
        lastAttackInChain = attackType
    }

    func canChainInto(attackType: AttackType) -> Bool {
        guard let last = lastAttackInChain else { return true }
        guard let lastIdx = chainOrder.firstIndex(of: last),
              let nextIdx = chainOrder.firstIndex(of: attackType) else { return true }
        return nextIdx > lastIdx
    }

    func resetCombo() {
        comboCount = 0
        lastAttackInChain = nil
    }

    /// Check input buffer for special move inputs.
    static func detectSpecialInput(buffer: InputBuffer) -> SpecialInput {
        let recent = buffer.recentDirections(count: 15)
        guard recent.count >= 3 else { return .none }

        // Quarter circle forward: ↓ → ↘ → →
        if containsSequence(recent, [.down, .downForward, .forward]) {
            return .quarterCircleForward
        }
        // Quarter circle back: ↓ → ↙ → ←
        if containsSequence(recent, [.down, .downBackward, .backward]) {
            return .quarterCircleBack
        }
        // Dragon punch: → → ↓ → ↘
        if containsSequence(recent, [.forward, .down, .downForward]) {
            return .dragonPunch
        }

        return .none
    }

    private static func containsSequence(_ buffer: [InputDirection], _ sequence: [InputDirection]) -> Bool {
        var seqIdx = 0
        for dir in buffer {
            if dir == sequence[seqIdx] {
                seqIdx += 1
                if seqIdx >= sequence.count { return true }
            }
        }
        return false
    }
}
