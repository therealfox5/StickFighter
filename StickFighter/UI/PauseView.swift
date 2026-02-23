import SwiftUI

struct PauseView: View {
    @EnvironmentObject var coordinator: GameCoordinator

    var body: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()

            VStack(spacing: 24) {
                Text("PAUSED")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)

                VStack(spacing: 12) {
                    Button("RESUME") {
                        coordinator.currentScreen = .fight
                    }
                    .buttonStyle(NavButtonStyle(primary: true))

                    Button("QUIT TO MENU") {
                        coordinator.fightScene = nil
                        coordinator.returnToMenu()
                    }
                    .buttonStyle(NavButtonStyle())
                }
            }
        }
    }
}
