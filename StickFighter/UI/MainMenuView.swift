import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var coordinator: GameCoordinator

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(hex: 0x0a0a1a), Color(hex: 0x1a1a3e)],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Title
                VStack(spacing: 8) {
                    Text("STICK")
                        .font(.system(size: 64, weight: .black, design: .default))
                        .foregroundColor(.white)
                    Text("FIGHTER")
                        .font(.system(size: 72, weight: .black, design: .default))
                        .foregroundColor(.yellow)
                }

                Spacer()

                // Menu buttons
                VStack(spacing: 16) {
                    MenuButton(title: "1 PLAYER", subtitle: "VS CPU") {
                        coordinator.gameMode = .singlePlayer
                        coordinator.currentScreen = .characterSelect
                    }

                    MenuButton(title: "2 PLAYERS", subtitle: "LOCAL") {
                        coordinator.gameMode = .twoPlayer
                        coordinator.currentScreen = .characterSelect
                    }
                }

                // Difficulty selector (single player)
                VStack(spacing: 8) {
                    Text("AI DIFFICULTY")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.gray)

                    HStack(spacing: 12) {
                        ForEach(AIDifficulty.allCases, id: \.rawValue) { diff in
                            Button(action: {
                                coordinator.aiDifficulty = diff
                            }) {
                                Text(diff.rawValue.uppercased())
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(coordinator.aiDifficulty == diff ? .black : .white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        coordinator.aiDifficulty == diff
                                            ? Color.yellow
                                            : Color(white: 0.2)
                                    )
                                    .cornerRadius(8)
                            }
                        }
                    }
                }

                Spacer()
            }
        }
    }
}

struct MenuButton: View {
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
            }
            .frame(width: 280, height: 60)
            .background(Color(white: 0.15))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.yellow.opacity(0.5), lineWidth: 2)
            )
            .cornerRadius(12)
        }
    }
}

extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}
