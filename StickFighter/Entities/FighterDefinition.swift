import CoreGraphics
import SpriteKit

/// Defines a character's stats and properties.
struct FighterDefinition {
    let id: CharacterID
    let displayName: String
    let color: SKColor
    let walkSpeed: CGFloat
    let jumpForce: CGFloat
    let maxHealth: CGFloat
    let damageMultiplier: CGFloat
    let lightStartup: Int       // base startup frames for light attacks
    let heavyStartup: Int       // base startup frames for heavy attacks
    let scale: CGFloat          // visual scale multiplier
}

/// Catalog of all character definitions.
enum FighterCatalog {
    static func definition(for id: CharacterID) -> FighterDefinition {
        switch id {
        case .kai:
            return FighterDefinition(
                id: .kai, displayName: "Kai", color: .white,
                walkSpeed: K.walkSpeed, jumpForce: K.jumpForce,
                maxHealth: K.maxHealth, damageMultiplier: 1.0,
                lightStartup: 3, heavyStartup: 8, scale: 1.0
            )
        case .brutus:
            return FighterDefinition(
                id: .brutus, displayName: "Brutus",
                color: SKColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1.0),
                walkSpeed: K.walkSpeed * 0.7, jumpForce: K.jumpForce * 0.85,
                maxHealth: K.maxHealth * 1.3, damageMultiplier: 1.3,
                lightStartup: 5, heavyStartup: 12, scale: 1.2
            )
        case .dash:
            return FighterDefinition(
                id: .dash, displayName: "Dash",
                color: SKColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1.0),
                walkSpeed: K.walkSpeed * 1.4, jumpForce: K.jumpForce * 1.15,
                maxHealth: K.maxHealth * 0.8, damageMultiplier: 0.85,
                lightStartup: 2, heavyStartup: 6, scale: 0.9
            )
        case .titan:
            return FighterDefinition(
                id: .titan, displayName: "Titan",
                color: SKColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0),
                walkSpeed: K.walkSpeed * 0.6, jumpForce: K.jumpForce * 0.75,
                maxHealth: K.maxHealth * 1.5, damageMultiplier: 1.4,
                lightStartup: 6, heavyStartup: 14, scale: 1.35
            )
        case .bolt:
            return FighterDefinition(
                id: .bolt, displayName: "Bolt",
                color: SKColor(red: 0.6, green: 0.4, blue: 1.0, alpha: 1.0),
                walkSpeed: K.walkSpeed * 1.1, jumpForce: K.jumpForce * 1.0,
                maxHealth: K.maxHealth * 0.9, damageMultiplier: 0.9,
                lightStartup: 3, heavyStartup: 8, scale: 0.95
            )
        }
    }
}
