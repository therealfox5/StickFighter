import Foundation

/// Tracks combat state like stun frames, invincibility, etc.
final class CombatComponent {
    var hitStunRemaining: Int = 0
    var blockStunRemaining: Int = 0
    var invincibilityFrames: Int = 0
    var isBlocking: Bool = false

    var isInHitStun: Bool { hitStunRemaining > 0 }
    var isInBlockStun: Bool { blockStunRemaining > 0 }
    var isInvincible: Bool { invincibilityFrames > 0 }

    func update() {
        if hitStunRemaining > 0 { hitStunRemaining -= 1 }
        if blockStunRemaining > 0 { blockStunRemaining -= 1 }
        if invincibilityFrames > 0 { invincibilityFrames -= 1 }
    }

    func reset() {
        hitStunRemaining = 0
        blockStunRemaining = 0
        invincibilityFrames = 0
        isBlocking = false
    }
}
