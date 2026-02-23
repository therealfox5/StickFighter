import Foundation

/// Provides animation clips for each character.
final class AnimationLibrary {
    static let shared = AnimationLibrary()

    private var clips: [CharacterID: [String: AnimationClip]] = [:]

    private init() {
        buildDefaultClips()
        buildCharacterOverrides()
    }

    func clip(for character: CharacterID, name: String) -> AnimationClip? {
        clips[character]?[name] ?? clips[.kai]?[name]
    }

    private func buildDefaultClips() {
        // Default clips (used by Kai, fallback for others)
        let idle = AnimationClip(name: "idle", keyframes: [
            AnimationKeyframe(pose: .idle, frameDuration: 40),
            AnimationKeyframe(pose: PoseData(
                leftShoulderAngle: .pi * 0.12,
                rightShoulderAngle: -.pi * 0.12,
                bodyOffsetY: -2
            ), frameDuration: 40),
        ], loops: true)

        let walk = AnimationClip(name: "walk", keyframes: [
            AnimationKeyframe(pose: .walkFrame1, frameDuration: 12),
            AnimationKeyframe(pose: .idle, frameDuration: 6),
            AnimationKeyframe(pose: .walkFrame2, frameDuration: 12),
            AnimationKeyframe(pose: .idle, frameDuration: 6),
        ], loops: true)

        let jump = AnimationClip(name: "jump", keyframes: [
            AnimationKeyframe(pose: .jump, frameDuration: 30),
        ])

        let crouchClip = AnimationClip(name: "crouch", keyframes: [
            AnimationKeyframe(pose: .crouch, frameDuration: 6),
        ])

        let lightPunch = AnimationClip(name: "lightPunch", keyframes: [
            AnimationKeyframe(pose: .lightPunchWindup, frameDuration: 3),  // startup
            AnimationKeyframe(pose: .lightPunchExtend, frameDuration: 3),  // active
            AnimationKeyframe(pose: .idle, frameDuration: 6),              // recovery
        ])

        let lightKick = AnimationClip(name: "lightKick", keyframes: [
            AnimationKeyframe(pose: .lightKickWindup, frameDuration: 4),
            AnimationKeyframe(pose: .lightKickExtend, frameDuration: 4),
            AnimationKeyframe(pose: .idle, frameDuration: 7),
        ])

        let heavyPunch = AnimationClip(name: "heavyPunch", keyframes: [
            AnimationKeyframe(pose: .heavyPunchWindup, frameDuration: 8),
            AnimationKeyframe(pose: .heavyPunchExtend, frameDuration: 5),
            AnimationKeyframe(pose: .idle, frameDuration: 12),
        ])

        let heavyKick = AnimationClip(name: "heavyKick", keyframes: [
            AnimationKeyframe(pose: .heavyKickWindup, frameDuration: 9),
            AnimationKeyframe(pose: .heavyKickExtend, frameDuration: 6),
            AnimationKeyframe(pose: .idle, frameDuration: 14),
        ])

        let blockClip = AnimationClip(name: "block", keyframes: [
            AnimationKeyframe(pose: .block, frameDuration: 60),
        ])

        let hitStunClip = AnimationClip(name: "hitStun", keyframes: [
            AnimationKeyframe(pose: .hitStun, frameDuration: 20),
        ])

        let knockdownClip = AnimationClip(name: "knockdown", keyframes: [
            AnimationKeyframe(pose: .hitStun, frameDuration: 6),
            AnimationKeyframe(pose: .knockdown, frameDuration: 30),
        ])

        let victoryClip = AnimationClip(name: "victory", keyframes: [
            AnimationKeyframe(pose: .victory, frameDuration: 60),
        ])

        let kaiClips: [String: AnimationClip] = [
            "idle": idle, "walk": walk, "jump": jump, "crouch": crouchClip,
            "lightPunch": lightPunch, "lightKick": lightKick,
            "heavyPunch": heavyPunch, "heavyKick": heavyKick,
            "block": blockClip, "hitStun": hitStunClip,
            "knockdown": knockdownClip, "victory": victoryClip,
        ]
        clips[.kai] = kaiClips
    }

    private func buildCharacterOverrides() {
        // Brutus: slower startup, longer active frames
        var brutusClips = clips[.kai]!
        brutusClips["lightPunch"] = AnimationClip(name: "lightPunch", keyframes: [
            AnimationKeyframe(pose: .lightPunchWindup, frameDuration: 5),
            AnimationKeyframe(pose: .lightPunchExtend, frameDuration: 5),
            AnimationKeyframe(pose: .idle, frameDuration: 8),
        ])
        brutusClips["heavyPunch"] = AnimationClip(name: "heavyPunch", keyframes: [
            AnimationKeyframe(pose: .heavyPunchWindup, frameDuration: 12),
            AnimationKeyframe(pose: .heavyPunchExtend, frameDuration: 7),
            AnimationKeyframe(pose: .idle, frameDuration: 16),
        ])
        clips[.brutus] = brutusClips

        // Dash: faster startup, shorter recovery
        var dashClips = clips[.kai]!
        dashClips["lightPunch"] = AnimationClip(name: "lightPunch", keyframes: [
            AnimationKeyframe(pose: .lightPunchWindup, frameDuration: 2),
            AnimationKeyframe(pose: .lightPunchExtend, frameDuration: 2),
            AnimationKeyframe(pose: .idle, frameDuration: 4),
        ])
        dashClips["walk"] = AnimationClip(name: "walk", keyframes: [
            AnimationKeyframe(pose: .walkFrame1, frameDuration: 8),
            AnimationKeyframe(pose: .idle, frameDuration: 4),
            AnimationKeyframe(pose: .walkFrame2, frameDuration: 8),
            AnimationKeyframe(pose: .idle, frameDuration: 4),
        ], loops: true)
        clips[.dash] = dashClips

        // Titan: even slower, powerful
        var titanClips = clips[.kai]!
        titanClips["heavyPunch"] = AnimationClip(name: "heavyPunch", keyframes: [
            AnimationKeyframe(pose: .heavyPunchWindup, frameDuration: 14),
            AnimationKeyframe(pose: .heavyPunchExtend, frameDuration: 8),
            AnimationKeyframe(pose: .idle, frameDuration: 18),
        ])
        clips[.titan] = titanClips

        // Bolt: standard timing (zoner relies on specials)
        clips[.bolt] = clips[.kai]!
    }
}
