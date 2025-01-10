import SwiftUI

enum AppScreen {
    case login
    case difficultySelection
    case game(difficulty: Difficulty)
}

struct ContentView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var currentScreen: AppScreen = .login

    var body: some View {
        NavigationView {
            VStack {
                switch currentScreen {
                case .login:
                    LoginView {
                        currentScreen = .difficultySelection
                    }
                case .difficultySelection:
                    DifficultySelectionView(authViewModel: authViewModel) { selectedDifficulty in
                        currentScreen = .game(difficulty: selectedDifficulty)
                    }
                case .game(let difficulty):
                    SudokuGameView(difficulty: difficulty) {
                        currentScreen = .difficultySelection
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                
                if authViewModel.currentUser == nil {
                    currentScreen = .login
                } else {
                    currentScreen = .difficultySelection
                }
            }
        }
    }
}

#Preview {
    ContentView(authViewModel: AuthViewModel())
}

