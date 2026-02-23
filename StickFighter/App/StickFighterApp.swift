import SwiftUI

@main
struct StickFighterApp: App {
    @StateObject private var coordinator = GameCoordinator()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(coordinator)
                .preferredColorScheme(.dark)
                .statusBarHidden()
        }
    }
}
