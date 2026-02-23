import SwiftUI

struct VictoryView: View {
    @EnvironmentObject var coordinator: GameCoordinator

    var body: some View {
        ZStack {
            Color(hex: 0x0a0a1a).ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                Text("WINNER!")
                    .font(.system(size: 48, weight: .black))
                    .foregroundColor(.yellow)

                Text(winnerName)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(winnerColor)

                Text(winnerLabel)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.gray)

                // Score
                HStack(spacing: 40) {
                    VStack {
                        Text("P1")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.cyan)
                        Text("\(coordinator.player1RoundWins)")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Text("-")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.gray)
                    VStack {
                        Text(coordinator.gameMode == .twoPlayer ? "P2" : "CPU")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.red)
                        Text("\(coordinator.player2RoundWins)")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                    }
                }

                Spacer()

                VStack(spacing: 12) {
                    Button("REMATCH") {
                        coordinator.fightScene = nil
                        coordinator.rematch()
                    }
                    .buttonStyle(NavButtonStyle(primary: true))

                    Button("CHARACTER SELECT") {
                        coordinator.fightScene = nil
                        coordinator.currentScreen = .characterSelect
                    }
                    .buttonStyle(NavButtonStyle())

                    Button("MAIN MENU") {
                        coordinator.fightScene = nil
                        coordinator.returnToMenu()
                    }
                    .buttonStyle(NavButtonStyle())
                }

                Spacer()
            }
        }
    }

    private var winnerName: String {
        if coordinator.matchWinner == 1 {
            return coordinator.player1Character.displayName
        }
        return coordinator.player2Character.displayName
    }

    private var winnerColor: Color {
        let charID = coordinator.matchWinner == 1 ? coordinator.player1Character : coordinator.player2Character
        switch charID {
        case .kai: return .white
        case .brutus: return Color(red: 1.0, green: 0.4, blue: 0.4)
        case .dash: return Color(red: 0.4, green: 0.8, blue: 1.0)
        case .titan: return Color(red: 1.0, green: 0.8, blue: 0.2)
        case .bolt: return Color(red: 0.6, green: 0.4, blue: 1.0)
        }
    }

    private var winnerLabel: String {
        if coordinator.matchWinner == 1 {
            return "PLAYER 1"
        }
        return coordinator.gameMode == .twoPlayer ? "PLAYER 2" : "CPU"
    }
}
