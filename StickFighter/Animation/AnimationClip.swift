import Foundation

/// A keyframe in an animation clip.
struct AnimationKeyframe {
    let pose: PoseData
    let frameDuration: Int  // duration in frames (1/60s each)
}

/// A named animation clip consisting of keyframes.
struct AnimationClip {
    let name: String
    let keyframes: [AnimationKeyframe]
    let loops: Bool
    let totalFrames: Int

    init(name: String, keyframes: [AnimationKeyframe], loops: Bool = false) {
        self.name = name
        self.keyframes = keyframes
        self.loops = loops
        self.totalFrames = keyframes.reduce(0) { $0 + $1.frameDuration }
    }

    /// Returns interpolated pose at the given frame.
    func poseAt(frame: Int) -> PoseData {
        guard !keyframes.isEmpty else { return .idle }
        guard keyframes.count > 1 else { return keyframes[0].pose }

        var effectiveFrame = frame
        if loops && totalFrames > 0 {
            effectiveFrame = frame % totalFrames
        } else {
            effectiveFrame = min(frame, totalFrames - 1)
        }

        var accumulated = 0
        for i in 0..<keyframes.count {
            let kf = keyframes[i]
            if accumulated + kf.frameDuration > effectiveFrame {
                let localT = CGFloat(effectiveFrame - accumulated) / CGFloat(kf.frameDuration)
                let nextIndex = (i + 1) % keyframes.count
                if !loops && i == keyframes.count - 1 {
                    return kf.pose
                }
                return PoseData.lerp(kf.pose, keyframes[nextIndex].pose, t: localT)
            }
            accumulated += kf.frameDuration
        }
        return keyframes.last?.pose ?? .idle
    }
}
