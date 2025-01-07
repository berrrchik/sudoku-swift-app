import SwiftUI

enum AppScreen {
    case difficultySelection
    case game(difficulty: Difficulty)
}

struct ContentView: View {
    @State private var currentScreen: AppScreen = .difficultySelection
    
    var body: some View {
        NavigationView {
            VStack {
                switch currentScreen {
                case .difficultySelection:
                    DifficultySelectionView { selectedDifficulty in
                        currentScreen = .game(difficulty: selectedDifficulty)
                    }
                case .game(let difficulty):
                    SudokuGameView(difficulty: difficulty) {
                        currentScreen = .difficultySelection
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    ContentView()
}
