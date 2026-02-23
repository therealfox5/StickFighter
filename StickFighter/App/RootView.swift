import SwiftUI
import SpriteKit

struct RootView: View {
    @EnvironmentObject var coordinator: GameCoordinator

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            switch coordinator.currentScreen {
            case .mainMenu:
                MainMenuView()
                    .transition(.opacity)
            case .characterSelect:
                CharacterSelectView()
                    .transition(.move(edge: .trailing))
            case .stageSelect:
                StageSelectView()
                    .transition(.move(edge: .trailing))
            case .fight:
                FightView()
                    .transition(.opacity)
            case .pause:
                FightView()
                    .overlay(PauseView())
            case .victory:
                VictoryView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: coordinator.currentScreen)
    }
}

struct FightView: View {
    @EnvironmentObject var coordinator: GameCoordinator

    var body: some View {
        GeometryReader { geo in
            SpriteView(scene: makeFightScene(size: geo.size), preferredFramesPerSecond: 60)
                .ignoresSafeArea()
        }
    }

    private func makeFightScene(size: CGSize) -> FightScene {
        if let existing = coordinator.fightScene, existing.size == size {
            return existing
        }
        let scene = FightScene(size: size)
        scene.scaleMode = .resizeFill
        scene.coordinator = coordinator
        coordinator.fightScene = scene
        return scene
    }
}
