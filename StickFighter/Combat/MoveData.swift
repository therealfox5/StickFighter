import CoreGraphics

/// Frame data for an attack move.
struct MoveData {
    let name: String
    let attackType: AttackType
    let damage: CGFloat
    let chipDamage: CGFloat
    let startupFrames: Int     // frames before hitbox becomes active
    let activeFrames: Int      // frames hitbox is active
    let recoveryFrames: Int    // frames after active before can act
    let hitStun: Int           // frames opponent is stuck in hitstun
    let blockStun: Int         // frames opponent is stuck in blockstun
    let knockback: CGVector    // knockback applied on hit
    let attackHeight: AttackHeight
    let hitType: HitType
    let hitboxSize: CGSize
    let hitboxOffset: CGPoint  // offset from fighter center (facing-adjusted)
    let animationClip: String
    let comboScaling: CGFloat  // additional scaling for this move in combos
    let cancelWindow: ClosedRange<Int>? // frames during which move can be cancelled

    var totalFrames: Int { startupFrames + activeFrames + recoveryFrames }

    /// Whether the given frame is in the active hitbox window.
    func isActive(at frame: Int) -> Bool {
        frame >= startupFrames && frame < startupFrames + activeFrames
    }

    /// Whether the given frame is in the cancel window.
    func canCancel(at frame: Int) -> Bool {
        guard let window = cancelWindow else { return false }
        return window.contains(frame)
    }
}

// MARK: - Default Moves

extension MoveData {
    static func lightPunch(for character: CharacterID) -> MoveData {
        let def = FighterCatalog.definition(for: character)
        return MoveData(
            name: "Light Punch", attackType: .lightPunch,
            damage: 5 * def.damageMultiplier,
            chipDamage: 1,
            startupFrames: def.lightStartup,
            activeFrames: 3,
            recoveryFrames: 6,
            hitStun: K.hitStunBase,
            blockStun: K.blockStunBase,
            knockback: CGVector(dx: K.knockbackBase * 0.5, dy: 0),
            attackHeight: .mid,
            hitType: .normal,
            hitboxSize: CGSize(width: 35, height: 20),
            hitboxOffset: CGPoint(x: 45, y: 60),
            animationClip: "lightPunch",
            comboScaling: 1.0,
            cancelWindow: 3...5
        )
    }

    static func lightKick(for character: CharacterID) -> MoveData {
        let def = FighterCatalog.definition(for: character)
        return MoveData(
            name: "Light Kick", attackType: .lightKick,
            damage: 6 * def.damageMultiplier,
            chipDamage: 1,
            startupFrames: def.lightStartup + 1,
            activeFrames: 4,
            recoveryFrames: 7,
            hitStun: K.hitStunBase + 2,
            blockStun: K.blockStunBase + 1,
            knockback: CGVector(dx: K.knockbackBase * 0.6, dy: 0),
            attackHeight: .low,
            hitType: .normal,
            hitboxSize: CGSize(width: 40, height: 18),
            hitboxOffset: CGPoint(x: 48, y: 20),
            animationClip: "lightKick",
            comboScaling: 1.0,
            cancelWindow: 4...7
        )
    }

    static func heavyPunch(for character: CharacterID) -> MoveData {
        let def = FighterCatalog.definition(for: character)
        return MoveData(
            name: "Heavy Punch", attackType: .heavyPunch,
            damage: 12 * def.damageMultiplier,
            chipDamage: 2,
            startupFrames: def.heavyStartup,
            activeFrames: 5,
            recoveryFrames: 12,
            hitStun: K.hitStunBase + 8,
            blockStun: K.blockStunBase + 5,
            knockback: CGVector(dx: K.knockbackBase, dy: 50),
            attackHeight: .mid,
            hitType: .normal,
            hitboxSize: CGSize(width: 42, height: 24),
            hitboxOffset: CGPoint(x: 50, y: 65),
            animationClip: "heavyPunch",
            comboScaling: 0.8,
            cancelWindow: nil
        )
    }

    static func heavyKick(for character: CharacterID) -> MoveData {
        let def = FighterCatalog.definition(for: character)
        return MoveData(
            name: "Heavy Kick", attackType: .heavyKick,
            damage: 14 * def.damageMultiplier,
            chipDamage: 3,
            startupFrames: def.heavyStartup + 1,
            activeFrames: 6,
            recoveryFrames: 14,
            hitStun: K.hitStunBase + 10,
            blockStun: K.blockStunBase + 6,
            knockback: CGVector(dx: K.knockbackBase * 1.2, dy: 80),
            attackHeight: .mid,
            hitType: .knockdown,
            hitboxSize: CGSize(width: 45, height: 22),
            hitboxOffset: CGPoint(x: 52, y: 25),
            animationClip: "heavyKick",
            comboScaling: 0.7,
            cancelWindow: nil
        )
    }

    static func special(for character: CharacterID) -> MoveData {
        let def = FighterCatalog.definition(for: character)
        switch character {
        case .kai:
            return MoveData(
                name: "Hadou Fist", attackType: .special,
                damage: 15 * def.damageMultiplier,
                chipDamage: 4,
                startupFrames: 10, activeFrames: 6, recoveryFrames: 18,
                hitStun: K.hitStunBase + 12,
                blockStun: K.blockStunBase + 8,
                knockback: CGVector(dx: K.knockbackBase * 1.5, dy: 100),
                attackHeight: .mid, hitType: .knockdown,
                hitboxSize: CGSize(width: 50, height: 30),
                hitboxOffset: CGPoint(x: 55, y: 60),
                animationClip: "heavyPunch", comboScaling: 0.6,
                cancelWindow: nil
            )
        case .brutus:
            return MoveData(
                name: "Hammer Fist", attackType: .special,
                damage: 22 * def.damageMultiplier,
                chipDamage: 5,
                startupFrames: 16, activeFrames: 8, recoveryFrames: 22,
                hitStun: K.hitStunBase + 18,
                blockStun: K.blockStunBase + 12,
                knockback: CGVector(dx: K.knockbackBase * 0.8, dy: 200),
                attackHeight: .overhead, hitType: .launch,
                hitboxSize: CGSize(width: 50, height: 35),
                hitboxOffset: CGPoint(x: 40, y: 70),
                animationClip: "heavyPunch", comboScaling: 0.5,
                cancelWindow: nil
            )
        case .dash:
            return MoveData(
                name: "Flash Kick", attackType: .special,
                damage: 12 * def.damageMultiplier,
                chipDamage: 3,
                startupFrames: 5, activeFrames: 4, recoveryFrames: 14,
                hitStun: K.hitStunBase + 8,
                blockStun: K.blockStunBase + 6,
                knockback: CGVector(dx: K.knockbackBase * 1.8, dy: 50),
                attackHeight: .mid, hitType: .wallBounce,
                hitboxSize: CGSize(width: 40, height: 25),
                hitboxOffset: CGPoint(x: 50, y: 30),
                animationClip: "heavyKick", comboScaling: 0.7,
                cancelWindow: nil
            )
        case .titan:
            return MoveData(
                name: "Giant Slam", attackType: .special,
                damage: 25 * def.damageMultiplier,
                chipDamage: 6,
                startupFrames: 18, activeFrames: 10, recoveryFrames: 24,
                hitStun: K.hitStunBase + 20,
                blockStun: K.blockStunBase + 14,
                knockback: CGVector(dx: K.knockbackBase * 0.5, dy: 250),
                attackHeight: .mid, hitType: .launch,
                hitboxSize: CGSize(width: 60, height: 40),
                hitboxOffset: CGPoint(x: 35, y: 50),
                animationClip: "heavyPunch", comboScaling: 0.4,
                cancelWindow: nil
            )
        case .bolt:
            return MoveData(
                name: "Lightning Bolt", attackType: .special,
                damage: 10 * def.damageMultiplier,
                chipDamage: 3,
                startupFrames: 8, activeFrames: 5, recoveryFrames: 16,
                hitStun: K.hitStunBase + 10,
                blockStun: K.blockStunBase + 8,
                knockback: CGVector(dx: K.knockbackBase * 2.0, dy: 30),
                attackHeight: .mid, hitType: .normal,
                hitboxSize: CGSize(width: 60, height: 20),
                hitboxOffset: CGPoint(x: 70, y: 55),
                animationClip: "heavyPunch", comboScaling: 0.8,
                cancelWindow: nil
            )
        }
    }
}
