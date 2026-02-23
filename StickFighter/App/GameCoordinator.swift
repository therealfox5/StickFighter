import SwiftUI
import SpriteKit

enum GameScreen {
    case mainMenu
    case characterSelect
    case stageSelect
    case fight
    case pause
    case victory
}

enum GameMode {
    case singlePlayer
    case twoPlayer
}

final class GameCoordinator: ObservableObject {
    @Published var currentScreen: GameScreen = .mainMenu
    @Published var gameMode: GameMode = .singlePlayer
    @Published var player1Character: CharacterID = .kai
    @Published var player2Character: CharacterID = .kai
    @Published var selectedArena: ArenaID = .dojo
    @Published var aiDifficulty: AIDifficulty = .medium

    // Round tracking
    @Published var player1RoundWins: Int = 0
    @Published var player2RoundWins: Int = 0
    @Published var currentRound: Int = 1
    @Published var matchWinner: Int? = nil
    let roundsToWin = 2

    var fightScene: FightScene?

    func startFight() {
        player1RoundWins = 0
        player2RoundWins = 0
        currentRound = 1
        matchWinner = nil
        currentScreen = .fight
    }

    func roundEnded(winner: Int) {
        if winner == 1 {
            player1RoundWins += 1
        } else {
            player2RoundWins += 1
        }

        if player1RoundWins >= roundsToWin {
            matchWinner = 1
            currentScreen = .victory
        } else if player2RoundWins >= roundsToWin {
            matchWinner = 2
            currentScreen = .victory
        } else {
            currentRound += 1
            fightScene?.startNewRound()
        }
    }

    func returnToMenu() {
        currentScreen = .mainMenu
    }

    func rematch() {
        startFight()
    }
}
