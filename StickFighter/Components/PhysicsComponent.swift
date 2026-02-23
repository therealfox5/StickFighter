import CoreGraphics

/// Handles fighter physics: gravity, velocity, ground collision.
final class PhysicsComponent {
    var velocity: CGVector = .zero
    var position: CGPoint = .zero
    var isGrounded: Bool = true
    var facing: FighterFacing = .right

    var walkSpeed: CGFloat = K.walkSpeed
    var jumpForce: CGFloat = K.jumpForce

    func applyGravity() {
        if !isGrounded {
            velocity.dy += K.gravity / 60.0
        }
    }

    func jump() {
        guard isGrounded else { return }
        velocity.dy = jumpForce
        isGrounded = false
    }

    func update() {
        applyGravity()
        position.x += velocity.dx / 60.0
        position.y += velocity.dy / 60.0

        // Ground collision
        if position.y <= K.groundY {
            position.y = K.groundY
            velocity.dy = 0
            isGrounded = true
        }

        // Stage bounds
        position.x = position.x.clamped(to: K.stageLeftBound...K.stageRightBound)
    }

    func applyKnockback(dx: CGFloat, dy: CGFloat) {
        velocity.dx = dx
        velocity.dy = dy
        if dy > 0 { isGrounded = false }
    }

    func stopHorizontal() {
        velocity.dx = 0
    }
}
