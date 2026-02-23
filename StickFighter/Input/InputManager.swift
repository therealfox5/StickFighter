import SpriteKit

/// Stores the current input state for a player.
struct InputState {
    var direction: InputDirection = .neutral
    var moveX: CGFloat = 0
    var moveY: CGFloat = 0
    var lightPunch: Bool = false
    var lightKick: Bool = false
    var heavyPunch: Bool = false
    var heavyKick: Bool = false
    var special: Bool = false
    var block: Bool = false

    var hasAttackInput: Bool {
        lightPunch || lightKick || heavyPunch || heavyKick || special
    }

    mutating func clearActions() {
        lightPunch = false
        lightKick = false
        heavyPunch = false
        heavyKick = false
        special = false
    }
}

/// Manages touch input zones for one or two players.
final class InputManager {
    var player1Input = InputState()
    var player2Input = InputState()
    var isTwoPlayer: Bool = false

    // Touch tracking
    private var activeTouches: [UITouch: TouchInfo] = [:]

    struct TouchInfo {
        let player: PlayerSlot
        let controlType: ControlType
    }

    enum ControlType {
        case joystick
        case button(FighterAction)
    }

    // Control layout rects (set by HUD)
    var p1JoystickCenter: CGPoint = .zero
    var p1JoystickRadius: CGFloat = 60
    var p1Buttons: [(rect: CGRect, action: FighterAction)] = []

    var p2JoystickCenter: CGPoint = .zero
    var p2JoystickRadius: CGFloat = 60
    var p2Buttons: [(rect: CGRect, action: FighterAction)] = []

    func touchBegan(_ touch: UITouch, at location: CGPoint) {
        // Determine which player this touch belongs to
        let slot = determinePlayer(for: location)

        if slot == .player1 {
            if let buttonAction = hitTestButtons(p1Buttons, at: location) {
                activeTouches[touch] = TouchInfo(player: .player1, controlType: .button(buttonAction))
                applyButtonPress(action: buttonAction, to: &player1Input)
            } else if location.distance(to: p1JoystickCenter) <= p1JoystickRadius * 2 {
                activeTouches[touch] = TouchInfo(player: .player1, controlType: .joystick)
                updateJoystick(center: p1JoystickCenter, radius: p1JoystickRadius,
                              touchPos: location, input: &player1Input)
            }
        } else {
            if let buttonAction = hitTestButtons(p2Buttons, at: location) {
                activeTouches[touch] = TouchInfo(player: .player2, controlType: .button(buttonAction))
                applyButtonPress(action: buttonAction, to: &player2Input)
            } else if location.distance(to: p2JoystickCenter) <= p2JoystickRadius * 2 {
                activeTouches[touch] = TouchInfo(player: .player2, controlType: .joystick)
                updateJoystick(center: p2JoystickCenter, radius: p2JoystickRadius,
                              touchPos: location, input: &player2Input)
            }
        }
    }

    func touchMoved(_ touch: UITouch, at location: CGPoint) {
        guard let info = activeTouches[touch] else { return }
        if case .joystick = info.controlType {
            if info.player == .player1 {
                updateJoystick(center: p1JoystickCenter, radius: p1JoystickRadius,
                              touchPos: location, input: &player1Input)
            } else {
                updateJoystick(center: p2JoystickCenter, radius: p2JoystickRadius,
                              touchPos: location, input: &player2Input)
            }
        }
    }

    func touchEnded(_ touch: UITouch) {
        guard let info = activeTouches.removeValue(forKey: touch) else { return }

        if case .joystick = info.controlType {
            if info.player == .player1 {
                player1Input.moveX = 0
                player1Input.moveY = 0
                player1Input.direction = .neutral
            } else {
                player2Input.moveX = 0
                player2Input.moveY = 0
                player2Input.direction = .neutral
            }
        }
    }

    func clearAll() {
        player1Input = InputState()
        player2Input = InputState()
        activeTouches.removeAll()
    }

    // MARK: - Private

    private func determinePlayer(for location: CGPoint) -> PlayerSlot {
        if !isTwoPlayer { return .player1 }
        // Left half = P1, Right half = P2
        return location.x < K.designWidth / 2 ? .player1 : .player2
    }

    private func hitTestButtons(_ buttons: [(rect: CGRect, action: FighterAction)],
                                at location: CGPoint) -> FighterAction? {
        for btn in buttons {
            if btn.rect.contains(location) { return btn.action }
        }
        return nil
    }

    private func applyButtonPress(action: FighterAction, to input: inout InputState) {
        switch action {
        case .lightPunch: input.lightPunch = true
        case .lightKick: input.lightKick = true
        case .heavyPunch: input.heavyPunch = true
        case .heavyKick: input.heavyKick = true
        case .special: input.special = true
        case .block: input.block = true
        case .jump: input.moveY = 1
        default: break
        }
    }

    private func updateJoystick(center: CGPoint, radius: CGFloat,
                                touchPos: CGPoint, input: inout InputState) {
        let dx = touchPos.x - center.x
        let dy = touchPos.y - center.y
        let dist = hypot(dx, dy)

        let normDist = min(dist / radius, 1.0)
        if dist > 0 {
            input.moveX = (dx / dist) * normDist
            input.moveY = (dy / dist) * normDist
        }

        // Determine direction
        let deadzone: CGFloat = 0.3
        let hasX = abs(input.moveX) > deadzone
        let hasY = abs(input.moveY) > deadzone
        let isRight = input.moveX > deadzone
        let isUp = input.moveY > deadzone

        if !hasX && !hasY {
            input.direction = .neutral
        } else if hasX && hasY {
            if isRight && isUp { input.direction = .upForward }
            else if !isRight && isUp { input.direction = .upBackward }
            else if isRight && !isUp { input.direction = .downForward }
            else { input.direction = .downBackward }
        } else if hasX {
            input.direction = isRight ? .forward : .backward
        } else {
            input.direction = isUp ? .up : .down
        }
    }
}
