import Foundation

enum FighterAction: Equatable {
    case idle
    case walkForward
    case walkBackward
    case jump
    case crouch
    case lightPunch
    case lightKick
    case heavyPunch
    case heavyKick
    case special
    case block
    case none
}

enum FighterFacing: CGFloat {
    case right = 1.0
    case left = -1.0
}

enum InputDirection: Equatable {
    case neutral
    case forward
    case backward
    case up
    case down
    case downForward
    case downBackward
    case upForward
    case upBackward
}

enum AttackType: String {
    case lightPunch = "LP"
    case lightKick = "LK"
    case heavyPunch = "HP"
    case heavyKick = "HK"
    case special = "SP"
}

enum AttackHeight {
    case high
    case mid
    case low
    case overhead
}

enum HitType {
    case normal
    case launch
    case knockdown
    case wallBounce
}

enum PlayerSlot: Int {
    case player1 = 1
    case player2 = 2
}

enum RoundPhase {
    case intro
    case fighting
    case ko
    case roundEnd
}

enum SpecialInput: Equatable {
    case quarterCircleForward  // ↓↘→
    case quarterCircleBack     // ↓↙←
    case dragonPunch           // →↓↘
    case chargeBack            // ←(hold)→
    case none
}
