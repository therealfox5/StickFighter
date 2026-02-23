import AVFoundation
import SpriteKit

/// Manages background music and sound effects.
final class AudioManager {
    static let shared = AudioManager()
    private var bgPlayer: AVAudioPlayer?
    private var isMuted = false

    private init() {}

    func playBGM(for arena: ArenaID) {
        // In a real app, load from Resources. For now, silent.
        bgPlayer?.stop()
    }

    func stopBGM() {
        bgPlayer?.stop()
    }

    func toggleMute() {
        isMuted.toggle()
        bgPlayer?.volume = isMuted ? 0 : 0.5
    }

    // SFX via SKAction (played on scene nodes)
    static func hitSound() -> SKAction {
        // Generate a short synth-like hit sound via wait (placeholder)
        // In production, load from audio files
        return SKAction.playSoundFileNamed("hit.wav", waitForCompletion: false)
    }

    static func blockSound() -> SKAction {
        return SKAction.playSoundFileNamed("block.wav", waitForCompletion: false)
    }

    static func koSound() -> SKAction {
        return SKAction.playSoundFileNamed("ko.wav", waitForCompletion: false)
    }

    /// Safe play — only plays if the file exists.
    static func safePlay(_ action: SKAction, on node: SKNode) {
        // SpriteKit will silently fail if file doesn't exist in newer iOS
        node.run(action)
    }
}
