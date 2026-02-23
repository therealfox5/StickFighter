import CoreGraphics

/// Joint angles (in radians) defining a stick figure pose.
/// All angles are relative to the parent bone's direction.
struct PoseData {
    // Head
    var headTilt: CGFloat = 0

    // Torso
    var torsoLean: CGFloat = 0  // forward/backward lean

    // Left arm
    var leftShoulderAngle: CGFloat = .pi * 0.1
    var leftElbowAngle: CGFloat = .pi * 0.15

    // Right arm
    var rightShoulderAngle: CGFloat = -.pi * 0.1
    var rightElbowAngle: CGFloat = -.pi * 0.15

    // Left leg
    var leftHipAngle: CGFloat = .pi * 0.05
    var leftKneeAngle: CGFloat = 0

    // Right leg
    var rightHipAngle: CGFloat = -.pi * 0.05
    var rightKneeAngle: CGFloat = 0

    // Body offset (for crouching, jumping frames)
    var bodyOffsetY: CGFloat = 0

    static func lerp(_ a: PoseData, _ b: PoseData, t: CGFloat) -> PoseData {
        PoseData(
            headTilt: angleLerp(a.headTilt, b.headTilt, t: t),
            torsoLean: angleLerp(a.torsoLean, b.torsoLean, t: t),
            leftShoulderAngle: angleLerp(a.leftShoulderAngle, b.leftShoulderAngle, t: t),
            leftElbowAngle: angleLerp(a.leftElbowAngle, b.leftElbowAngle, t: t),
            rightShoulderAngle: angleLerp(a.rightShoulderAngle, b.rightShoulderAngle, t: t),
            rightElbowAngle: angleLerp(a.rightElbowAngle, b.rightElbowAngle, t: t),
            leftHipAngle: angleLerp(a.leftHipAngle, b.leftHipAngle, t: t),
            leftKneeAngle: angleLerp(a.leftKneeAngle, b.leftKneeAngle, t: t),
            rightHipAngle: angleLerp(a.rightHipAngle, b.rightHipAngle, t: t),
            rightKneeAngle: angleLerp(a.rightKneeAngle, b.rightKneeAngle, t: t),
            bodyOffsetY: .lerp(a.bodyOffsetY, b.bodyOffsetY, t: t)
        )
    }
}

// MARK: - Standard Poses

extension PoseData {
    static let idle = PoseData()

    static let walkFrame1 = PoseData(
        leftShoulderAngle: .pi * 0.3,
        leftElbowAngle: .pi * 0.1,
        rightShoulderAngle: -.pi * 0.3,
        rightElbowAngle: -.pi * 0.1,
        leftHipAngle: -.pi * 0.2,
        leftKneeAngle: .pi * 0.1,
        rightHipAngle: .pi * 0.2,
        rightKneeAngle: -.pi * 0.1
    )

    static let walkFrame2 = PoseData(
        leftShoulderAngle: -.pi * 0.3,
        leftElbowAngle: -.pi * 0.1,
        rightShoulderAngle: .pi * 0.3,
        rightElbowAngle: .pi * 0.1,
        leftHipAngle: .pi * 0.2,
        leftKneeAngle: -.pi * 0.1,
        rightHipAngle: -.pi * 0.2,
        rightKneeAngle: .pi * 0.1
    )

    static let jump = PoseData(
        leftShoulderAngle: .pi * 0.6,
        leftElbowAngle: .pi * 0.3,
        rightShoulderAngle: -.pi * 0.6,
        rightElbowAngle: -.pi * 0.3,
        leftHipAngle: -.pi * 0.3,
        leftKneeAngle: -.pi * 0.4,
        rightHipAngle: .pi * 0.3,
        rightKneeAngle: .pi * 0.4,
        bodyOffsetY: 0
    )

    static let crouch = PoseData(
        torsoLean: .pi * 0.1,
        leftShoulderAngle: .pi * 0.2,
        leftElbowAngle: .pi * 0.4,
        rightShoulderAngle: -.pi * 0.2,
        rightElbowAngle: -.pi * 0.4,
        leftHipAngle: .pi * 0.5,
        leftKneeAngle: -.pi * 0.7,
        rightHipAngle: -.pi * 0.5,
        rightKneeAngle: .pi * 0.7,
        bodyOffsetY: -20
    )

    static let lightPunchWindup = PoseData(
        torsoLean: -.pi * 0.05,
        leftShoulderAngle: .pi * 0.1,
        leftElbowAngle: .pi * 0.2,
        rightShoulderAngle: -.pi * 0.8,
        rightElbowAngle: -.pi * 0.6
    )

    static let lightPunchExtend = PoseData(
        torsoLean: .pi * 0.1,
        leftShoulderAngle: .pi * 0.1,
        leftElbowAngle: .pi * 0.1,
        rightShoulderAngle: .pi * 0.5,
        rightElbowAngle: .pi * 0.02
    )

    static let lightKickWindup = PoseData(
        torsoLean: -.pi * 0.1,
        leftShoulderAngle: .pi * 0.3,
        rightShoulderAngle: -.pi * 0.3,
        rightHipAngle: -.pi * 0.3,
        rightKneeAngle: -.pi * 0.5
    )

    static let lightKickExtend = PoseData(
        torsoLean: -.pi * 0.15,
        leftShoulderAngle: .pi * 0.3,
        rightShoulderAngle: -.pi * 0.3,
        rightHipAngle: .pi * 0.6,
        rightKneeAngle: .pi * 0.05
    )

    static let heavyPunchWindup = PoseData(
        torsoLean: -.pi * 0.15,
        leftShoulderAngle: .pi * 0.2,
        leftElbowAngle: .pi * 0.3,
        rightShoulderAngle: -.pi * 1.0,
        rightElbowAngle: -.pi * 0.7
    )

    static let heavyPunchExtend = PoseData(
        torsoLean: .pi * 0.2,
        leftShoulderAngle: -.pi * 0.1,
        leftElbowAngle: -.pi * 0.1,
        rightShoulderAngle: .pi * 0.6,
        rightElbowAngle: .pi * 0.02,
        rightHipAngle: -.pi * 0.1
    )

    static let heavyKickWindup = PoseData(
        torsoLean: -.pi * 0.2,
        leftShoulderAngle: .pi * 0.4,
        rightShoulderAngle: -.pi * 0.4,
        rightHipAngle: -.pi * 0.5,
        rightKneeAngle: -.pi * 0.6
    )

    static let heavyKickExtend = PoseData(
        torsoLean: -.pi * 0.25,
        leftShoulderAngle: .pi * 0.4,
        rightShoulderAngle: -.pi * 0.4,
        rightHipAngle: .pi * 0.8,
        rightKneeAngle: .pi * 0.02,
        leftHipAngle: -.pi * 0.1
    )

    static let block = PoseData(
        torsoLean: -.pi * 0.05,
        leftShoulderAngle: .pi * 0.7,
        leftElbowAngle: .pi * 0.8,
        rightShoulderAngle: -.pi * 0.5,
        rightElbowAngle: -.pi * 0.9
    )

    static let hitStun = PoseData(
        torsoLean: -.pi * 0.15,
        leftShoulderAngle: .pi * 0.4,
        leftElbowAngle: .pi * 0.2,
        rightShoulderAngle: -.pi * 0.4,
        rightElbowAngle: -.pi * 0.2,
        leftHipAngle: -.pi * 0.1,
        rightHipAngle: .pi * 0.1
    )

    static let knockdown = PoseData(
        torsoLean: -.pi * 0.45,
        leftShoulderAngle: .pi * 0.6,
        leftElbowAngle: .pi * 0.1,
        rightShoulderAngle: -.pi * 0.6,
        rightElbowAngle: -.pi * 0.1,
        leftHipAngle: .pi * 0.3,
        leftKneeAngle: -.pi * 0.2,
        rightHipAngle: -.pi * 0.3,
        rightKneeAngle: .pi * 0.2,
        bodyOffsetY: -30
    )

    static let victory = PoseData(
        leftShoulderAngle: .pi * 0.9,
        leftElbowAngle: .pi * 0.3,
        rightShoulderAngle: -.pi * 0.9,
        rightElbowAngle: -.pi * 0.3,
        leftHipAngle: .pi * 0.1,
        rightHipAngle: -.pi * 0.1
    )
}
