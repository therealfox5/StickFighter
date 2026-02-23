import Foundation

/// Circular buffer storing recent input directions for combo/special detection.
final class InputBuffer {
    private var buffer: [InputDirection]
    private var head: Int = 0
    private let capacity: Int

    init(capacity: Int = K.inputBufferSize) {
        self.capacity = capacity
        self.buffer = Array(repeating: .neutral, count: capacity)
    }

    func push(_ direction: InputDirection) {
        buffer[head] = direction
        head = (head + 1) % capacity
    }

    /// Returns the most recent `count` directions, newest first.
    func recentDirections(count: Int) -> [InputDirection] {
        var result: [InputDirection] = []
        for i in 0..<min(count, capacity) {
            let idx = (head - 1 - i + capacity) % capacity
            result.append(buffer[idx])
        }
        return result.reversed()
    }

    func clear() {
        buffer = Array(repeating: .neutral, count: capacity)
        head = 0
    }
}
