import Foundation

/// Drives animation playback for a fighter.
final class AnimationComponent {
    private(set) var currentClipName: String = "idle"
    private var currentClip: AnimationClip?
    private(set) var currentFrame: Int = 0
    private(set) var isFinished: Bool = false

    var characterID: CharacterID = .kai

    var currentPose: PoseData {
        currentClip?.poseAt(frame: currentFrame) ?? .idle
    }

    func play(_ clipName: String, forceRestart: Bool = false) {
        if clipName == currentClipName && !forceRestart && !isFinished { return }
        currentClipName = clipName
        currentClip = AnimationLibrary.shared.clip(for: characterID, name: clipName)
        currentFrame = 0
        isFinished = false
    }

    func update() {
        guard let clip = currentClip else { return }
        currentFrame += 1

        if clip.loops {
            if clip.totalFrames > 0 {
                currentFrame = currentFrame % clip.totalFrames
            }
        } else if currentFrame >= clip.totalFrames {
            isFinished = true
            currentFrame = clip.totalFrames - 1
        }
    }
}
