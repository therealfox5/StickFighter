import SwiftUI

struct StageSelectView: View {
    @EnvironmentObject var coordinator: GameCoordinator

    var body: some View {
        ZStack {
            Color(hex: 0x0a0a1a).ignoresSafeArea()

            VStack(spacing: 24) {
                Text("SELECT STAGE")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(ArenaID.allCases) { arena in
                        StageCard(
                            arena: arena,
                            isSelected: coordinator.selectedArena == arena
                        ) {
                            coordinator.selectedArena = arena
                        }
                    }
                }
                .padding(.horizontal, 60)

                HStack(spacing: 20) {
                    Button("BACK") {
                        coordinator.currentScreen = .characterSelect
                    }
                    .buttonStyle(NavButtonStyle())

                    Button("FIGHT!") {
                        coordinator.startFight()
                    }
                    .buttonStyle(NavButtonStyle(primary: true))
                }
                .padding(.top, 10)
            }
            .padding()
        }
    }
}

struct StageCard: View {
    let arena: ArenaID
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Stage preview (colored rectangle)
                Rectangle()
                    .fill(arenaColor)
                    .frame(height: 100)
                    .overlay(
                        Text(arena.displayName)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 2)
                    )
                    .cornerRadius(8)

                Text(arenaDescription)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            .padding(8)
            .background(Color(white: isSelected ? 0.2 : 0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.yellow : Color(white: 0.3), lineWidth: isSelected ? 3 : 1)
            )
            .cornerRadius(12)
        }
    }

    private var arenaColor: Color {
        switch arena {
        case .dojo: return Color(hex: 0x1a1a2e)
        case .rooftop: return Color(hex: 0x0a0a1a)
        case .pit: return Color(hex: 0x0d0d0d)
        case .skyTemple: return Color(hex: 0x87ceeb)
        }
    }

    private var arenaDescription: String {
        switch arena {
        case .dojo: return "Traditional training hall"
        case .rooftop: return "City skyline at night"
        case .pit: return "Underground fighting pit"
        case .skyTemple: return "Ancient temple in the clouds"
        }
    }
}
