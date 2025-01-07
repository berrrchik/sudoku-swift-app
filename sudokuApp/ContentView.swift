import SwiftUI

extension View {
    func buttonStyle(systemImage: String? = nil, title: String? = nil, background: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack {
                if let systemImage = systemImage {
                    Image(systemName: systemImage)
                        .resizable()
                        .scaledToFit()
                        .padding(6)
                }
                if let title = title {
                    Text(title)
                        .font(.system(size: 35))
                }
            }
        }
        .frame(width: 55, height: 55)
        .background(background)
        .foregroundColor(.white)
        .cornerRadius(8)
    }
}

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

struct DifficultySelectionView: View {
    let onDifficultySelected: (Difficulty) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Выберите уровень сложности")
                .multilineTextAlignment(.center)
                .font(.title)
                .padding()
            
            difficultyButton(title: "Лёгкий", color: .green, difficulty: .easy)
            difficultyButton(title: "Средний", color: .orange, difficulty: .medium)
            difficultyButton(title: "Тяжёлый", color: .red, difficulty: .hard)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
        .ignoresSafeArea()
    }
    
    private func difficultyButton(title: String, color: Color, difficulty: Difficulty) -> some View {
        Button(title) {
            onDifficultySelected(difficulty)
        }
        .frame(width: 150, height: 80)
        .background(color)
        .foregroundColor(.white)
        .cornerRadius(8)
        .font(.system(size: 25).bold())
    }
}

struct SudokuGameView: View {
    let difficulty: Difficulty
    @StateObject private var viewModel = SudokuViewModel()
    @State private var selectedCell: SudokuCoordinate? = nil
    @State private var resultMessage: String? = nil
    @State private var isSolutionRevealed = false
    let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: -10) {
            HStack(spacing: 20) {
                buttonStyle(systemImage: "arrow.uturn.backward", background: .blue) {
                    onBack()
                }
                .padding()
                Spacer()
                buttonStyle(systemImage: "play", background: .green) {
                    isSolutionRevealed = false
                    viewModel.isGameStarted = true
                    viewModel.startGame(difficulty: difficulty)
                }
                
                buttonStyle(systemImage: "checkmark", background: .red) {
                    isSolutionRevealed = true
                    viewModel.fillWithSolution()
                }
            }
            
            SudokuGridView(
                grid: $viewModel.grid,
                notes: $viewModel.notes,
                fixedCells: viewModel.fixedCells,
                selectedCell: $selectedCell
            )
            .padding()
            
            numberButtons()
                .padding()
            
            HStack(spacing: 25) {
//                buttonStyle(systemImage: "magnifyingglass", background: .blue) {
//                    guard !isSolutionRevealed, viewModel.isGameStarted else { return }
//                    resultMessage = viewModel.isSolutionCorrect() ? "Правильно" : "Неправильно"
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                        resultMessage = nil
//                    }
//                }
                
                buttonStyle(systemImage: "lightbulb", background: .orange) {
                    if !isSolutionRevealed {
                        viewModel.provideHint(for: selectedCell)
                    }
                }
                
                buttonStyle(systemImage: "trash", background: .black) {
                    if !isSolutionRevealed, let cell = selectedCell {
                        viewModel.clearCell(row: cell.row, col: cell.col)
                    }
                }
                
                buttonStyle(systemImage: "arrow.uturn.backward.circle", background: .pink) {
                    if !isSolutionRevealed {
                        viewModel.undoLastAction()
                    }
                }
                
                buttonStyle(systemImage: "pencil", background: viewModel.isNoteMode ? .blue : .gray) {
                    if !isSolutionRevealed {
                        if let cell = selectedCell {
                            viewModel.toggleNoteMode(row: cell.row, col: cell.col)
                        }
                    }
                }
            }
            .padding()
            
//            Text(resultMessage ?? "")
//                .font(.title)
//                .fontWeight(.bold)
//                .foregroundColor(resultMessage == "Правильно" ? .green : .red)
//                .opacity(resultMessage == nil ? 0 : 1)
        }
        .onAppear {
            viewModel.grid = Array(repeating: Array(repeating: 0, count: 9), count: 9)
        }
        .padding()
    }
    
    private func numberButtons() -> some View {
        VStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: 4) {
                    ForEach(1...3, id: \.self) { col in
                        let number = row * 3 + col
                        buttonStyle(title: "\(number)", background: .black) {
                            if !isSolutionRevealed, let cell = selectedCell {
                                viewModel.updateCell(row: cell.row, col: cell.col, value: number)
                            }
                        }
                    }
                }
            }
        }
    }
}


#Preview {
    ContentView()
}
