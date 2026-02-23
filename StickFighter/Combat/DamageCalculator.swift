import CoreGraphics

struct DamageResult {
    let damage: CGFloat
    let hitStun: Int
    let blockStun: Int
    let knockback: CGVector
    let wasBlocked: Bool
}

final class DamageCalculator {
    /// Calculate damage considering blocking, combo scaling, etc.
    static func calculate(move: MoveData, comboCount: Int, isBlocking: Bool,
                          attackerFacing: FighterFacing) -> DamageResult {
        let facingSign = attackerFacing.rawValue
        let scaling = max(K.minComboScaling, 1.0 - CGFloat(comboCount) * K.comboScalingPerHit) * move.comboScaling

        if isBlocking {
            return DamageResult(
                damage: move.chipDamage * scaling,
                hitStun: 0,
                blockStun: move.blockStun,
                knockback: CGVector(dx: move.knockback.dx * 0.3 * facingSign, dy: 0),
                wasBlocked: true
            )
        }

        return DamageResult(
            damage: move.damage * scaling,
            hitStun: move.hitStun,
            blockStun: 0,
            knockback: CGVector(dx: move.knockback.dx * facingSign, dy: move.knockback.dy),
            wasBlocked: false
        )
    }
}
