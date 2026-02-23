import CoreGraphics

final class HealthComponent {
    let maxHealth: CGFloat
    private(set) var currentHealth: CGFloat
    var isAlive: Bool { currentHealth > 0 }
    var healthPercent: CGFloat { currentHealth / maxHealth }

    init(maxHealth: CGFloat = K.maxHealth) {
        self.maxHealth = maxHealth
        self.currentHealth = maxHealth
    }

    @discardableResult
    func takeDamage(_ amount: CGFloat) -> CGFloat {
        let actual = min(currentHealth, amount)
        currentHealth = max(0, currentHealth - amount)
        return actual
    }

    func heal(_ amount: CGFloat) {
        currentHealth = min(maxHealth, currentHealth + amount)
    }

    func reset() {
        currentHealth = maxHealth
    }
}
