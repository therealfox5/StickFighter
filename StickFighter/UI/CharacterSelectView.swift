import SwiftUI

struct CharacterSelectView: View {
    @EnvironmentObject var coordinator: GameCoordinator
    @State private var selectingPlayer: Int = 1

    var body: some View {
        ZStack {
            Color(hex: 0x0a0a1a).ignoresSafeArea()

            VStack(spacing: 20) {
                // Header
                Text(selectingText)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)

                // Character grid
                LazyVGrid(columns: [
                    GridItem(.flexible()), GridItem(.flexible()),
                    GridItem(.flexible()), GridItem(.flexible()),
                    GridItem(.flexible()),
                ], spacing: 16) {
                    ForEach(CharacterID.allCases) { charID in
                        CharacterCard(
                            character: charID,
                            isSelected: isSelected(charID),
                            isP1: coordinator.player1Character == charID,
                            isP2: coordinator.player2Character == charID
                        ) {
                            selectCharacter(charID)
                        }
                    }
                }
                .padding(.horizontal, 40)

                // Selected characters display
                HStack(spacing: 60) {
                    VStack {
                        Text("P1")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.cyan)
                        Text(coordinator.player1Character.displayName)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                    }

                    if coordinator.gameMode == .twoPlayer {
                        VStack {
                            Text("P2")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.red)
                            Text(coordinator.player2Character.displayName)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                        }
                    } else {
                        VStack {
                            Text("CPU")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.red)
                            Text(coordinator.player2Character.displayName)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }

                // Navigation
                HStack(spacing: 20) {
                    Button("BACK") {
                        if selectingPlayer == 2 && coordinator.gameMode == .twoPlayer {
                            selectingPlayer = 1
                        } else {
                            coordinator.currentScreen = .mainMenu
                        }
                    }
                    .buttonStyle(NavButtonStyle())

                    if canProceed {
                        Button("NEXT") {
                            coordinator.currentScreen = .stageSelect
                        }
                        .buttonStyle(NavButtonStyle(primary: true))
                    }
                }
                .padding(.top, 10)
            }
            .padding()
        }
    }

    private var selectingText: String {
        if coordinator.gameMode == .twoPlayer {
            return selectingPlayer == 1 ? "PLAYER 1 — SELECT CHARACTER" : "PLAYER 2 — SELECT CHARACTER"
        }
        return "SELECT YOUR CHARACTER"
    }

    private var canProceed: Bool {
        if coordinator.gameMode == .twoPlayer {
            return selectingPlayer == 2 || selectingPlayer > 2
        }
        return true
    }

    private func isSelected(_ charID: CharacterID) -> Bool {
        if selectingPlayer == 1 { return coordinator.player1Character == charID }
        return coordinator.player2Character == charID
    }

    private func selectCharacter(_ charID: CharacterID) {
        if coordinator.gameMode == .singlePlayer {
            coordinator.player1Character = charID
            // Random opponent
            let others = CharacterID.allCases.filter { $0 != charID }
            coordinator.player2Character = others.randomElement() ?? .kai
        } else {
            if selectingPlayer == 1 {
                coordinator.player1Character = charID
                selectingPlayer = 2
            } else {
                coordinator.player2Character = charID
            }
        }
    }
}

struct CharacterCard: View {
    let character: CharacterID
    let isSelected: Bool
    let isP1: Bool
    let isP2: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                // Stick figure silhouette
                ZStack {
                    Circle()
                        .fill(Color(hex: 0x1a1a2e))
                        .frame(width: 70, height: 70)

                    StickFigureSilhouette(color: characterSwiftUIColor)
                        .frame(width: 40, height: 60)
                }

                Text(character.displayName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)

                Text(character.description)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
            .frame(width: 120, height: 130)
            .background(Color(white: isSelected ? 0.2 : 0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(borderColor, lineWidth: isSelected ? 3 : 1)
            )
            .cornerRadius(10)
        }
    }

    private var characterSwiftUIColor: Color {
        switch character {
        case .kai: return .white
        case .brutus: return Color(red: 1.0, green: 0.4, blue: 0.4)
        case .dash: return Color(red: 0.4, green: 0.8, blue: 1.0)
        case .titan: return Color(red: 1.0, green: 0.8, blue: 0.2)
        case .bolt: return Color(red: 0.6, green: 0.4, blue: 1.0)
        }
    }

    private var borderColor: Color {
        if isP1 && isP2 { return .purple }
        if isP1 { return .cyan }
        if isP2 { return .red }
        return Color(white: 0.3)
    }
}

struct StickFigureSilhouette: View {
    let color: Color

    var body: some View {
        Canvas { context, size in
            let midX = size.width / 2
            let headR: CGFloat = 6
            let headY: CGFloat = headR + 2

            // Head
            context.stroke(
                Path(ellipseIn: CGRect(x: midX - headR, y: headY - headR,
                                       width: headR * 2, height: headR * 2)),
                with: .color(color), lineWidth: 2
            )

            // Torso
            var torso = Path()
            torso.move(to: CGPoint(x: midX, y: headY + headR))
            torso.addLine(to: CGPoint(x: midX, y: headY + headR + 22))
            context.stroke(torso, with: .color(color), lineWidth: 2)

            let torsoBottom = headY + headR + 22

            // Arms
            var arms = Path()
            arms.move(to: CGPoint(x: midX - 12, y: torsoBottom - 12))
            arms.addLine(to: CGPoint(x: midX, y: torsoBottom - 16))
            arms.addLine(to: CGPoint(x: midX + 12, y: torsoBottom - 12))
            context.stroke(arms, with: .color(color), lineWidth: 2)

            // Legs
            var legs = Path()
            legs.move(to: CGPoint(x: midX - 10, y: size.height - 2))
            legs.addLine(to: CGPoint(x: midX, y: torsoBottom))
            legs.addLine(to: CGPoint(x: midX + 10, y: size.height - 2))
            context.stroke(legs, with: .color(color), lineWidth: 2)
        }
    }
}

struct NavButtonStyle: ButtonStyle {
    var primary: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(primary ? .black : .white)
            .padding(.horizontal, 30)
            .padding(.vertical, 12)
            .background(primary ? Color.yellow : Color(white: 0.2))
            .cornerRadius(8)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}
