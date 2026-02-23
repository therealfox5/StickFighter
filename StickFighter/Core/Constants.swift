import CoreGraphics
import SpriteKit

enum K {
    // Screen & layout
    static let designWidth: CGFloat = 1334
    static let designHeight: CGFloat = 750
    static let groundY: CGFloat = 100
    static let stageLeftBound: CGFloat = 60
    static let stageRightBound: CGFloat = 1274

    // Physics
    static let gravity: CGFloat = -1800
    static let walkSpeed: CGFloat = 300
    static let jumpForce: CGFloat = 700
    static let airControl: CGFloat = 0.5
    static let pushbackSpeed: CGFloat = 200

    // Combat
    static let maxHealth: CGFloat = 100
    static let chipDamageMultiplier: CGFloat = 0.2
    static let comboScalingPerHit: CGFloat = 0.1
    static let minComboScaling: CGFloat = 0.3
    static let hitStunBase: Int = 15
    static let blockStunBase: Int = 10
    static let knockbackBase: CGFloat = 250

    // Timing (frames at 60fps)
    static let inputBufferSize: Int = 30
    static let roundTime: Int = 99 // seconds
    static let koSlowdownFrames: Int = 60

    // Categories for physics
    struct Category {
        static let fighter: UInt32    = 0x1 << 0
        static let ground: UInt32     = 0x1 << 1
        static let hitbox: UInt32     = 0x1 << 2
        static let hurtbox: UInt32    = 0x1 << 3
        static let wall: UInt32       = 0x1 << 4
        static let projectile: UInt32 = 0x1 << 5
    }

    // Z positions
    struct ZPos {
        static let background: CGFloat = 0
        static let arenaDetail: CGFloat = 1
        static let fighter: CGFloat = 10
        static let effect: CGFloat = 20
        static let hud: CGFloat = 50
        static let announcement: CGFloat = 100
    }

    // Stick figure proportions
    struct Body {
        static let headRadius: CGFloat = 14
        static let torsoLength: CGFloat = 40
        static let upperArmLength: CGFloat = 22
        static let lowerArmLength: CGFloat = 20
        static let upperLegLength: CGFloat = 25
        static let lowerLegLength: CGFloat = 23
        static let lineWidth: CGFloat = 3.5
        static let jointRadius: CGFloat = 2.5
    }
}

enum CharacterID: String, CaseIterable, Identifiable {
    case kai, brutus, dash, titan, bolt
    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .kai: return "Kai"
        case .brutus: return "Brutus"
        case .dash: return "Dash"
        case .titan: return "Titan"
        case .bolt: return "Bolt"
        }
    }

    var description: String {
        switch self {
        case .kai: return "Balanced"
        case .brutus: return "Heavy / Slow"
        case .dash: return "Fast / Fragile"
        case .titan: return "Grappler"
        case .bolt: return "Zoner"
        }
    }

    var color: SKColor {
        switch self {
        case .kai: return .white
        case .brutus: return SKColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1.0)
        case .dash: return SKColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1.0)
        case .titan: return SKColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0)
        case .bolt: return SKColor(red: 0.6, green: 0.4, blue: 1.0, alpha: 1.0)
        }
    }
}

enum ArenaID: String, CaseIterable, Identifiable {
    case dojo, rooftop, pit, skyTemple
    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .dojo: return "Dojo"
        case .rooftop: return "Rooftop"
        case .pit: return "The Pit"
        case .skyTemple: return "Sky Temple"
        }
    }
}

enum AIDifficulty: String, CaseIterable {
    case easy, medium, hard

    var reactionDelay: Int {
        switch self {
        case .easy: return 30
        case .medium: return 15
        case .hard: return 5
        }
    }

    var accuracy: CGFloat {
        switch self {
        case .easy: return 0.3
        case .medium: return 0.6
        case .hard: return 0.9
        }
    }
}
