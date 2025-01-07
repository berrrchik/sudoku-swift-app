import SwiftUI

extension View {
    func styledButton(background: Color) -> some View {
        self.frame(width: 90, height: 40)
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
            
            Button("Лёгкий") {
                onDifficultySelected(.easy)
            }
            .styledButton(background: Color.green)
            
            Button("Средний") {
                onDifficultySelected(.medium)
            }
            .styledButton(background: Color.orange)
            
            Button("Сложный") {
                onDifficultySelected(.hard)
            }
            .styledButton(background: Color.red)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
        .ignoresSafeArea()
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
        VStack(spacing: -3) {
            HStack {
                Button("Назад") {
                    onBack()
                }
                .styledButton(background: Color.blue)
                .padding()
                Spacer()
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
            
            HStack {
                Button("Начать") {
                    isSolutionRevealed = false
                    viewModel.isGameStarted = true
                    viewModel.startGame(difficulty: difficulty)
                }
                .styledButton(background: Color.green)
                
                Button("Ответ") {
                    isSolutionRevealed = true
                    viewModel.fillWithSolution()
                }
                .styledButton(background: Color.red)
                
                Button("Проверить") {
                    guard !isSolutionRevealed, viewModel.isGameStarted else { return }
                    resultMessage = viewModel.isSolutionCorrect() ? "Правильно" : "Неправильно"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        resultMessage = nil
                    }
                }
                .styledButton(background: Color.blue)
                
                Button("Подсказка") {
                    if !isSolutionRevealed {
                        viewModel.provideHint(for: selectedCell)
                    }
                }
                .styledButton(background: Color.orange)
            }
            .padding()
            
            actionButtons()
            
            Text(resultMessage ?? "")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(resultMessage == "Правильно" ? .green : .red)
                .opacity(resultMessage == nil ? 0 : 1)
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
                        Button("\(number)") {
                            if !isSolutionRevealed, let cell = selectedCell {
                                viewModel.updateCell(row: cell.row, col: cell.col, value: number)
                            }
                        }
                        .frame(width: 50, height: 50)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .font(.system(size: 35))
                    }
                }
            }
        }
    }
    
    private func actionButtons() -> some View {
        HStack {
            Button("Удалить") {
                if !isSolutionRevealed, let cell = selectedCell {
                    viewModel.clearCell(row: cell.row, col: cell.col)
                }
            }
            .styledButton(background: Color.black)
            
            Button("Назад") {
                if !isSolutionRevealed {
                    viewModel.undoLastAction()
                }
            }
            .styledButton(background: Color.pink)
            
            Button(action: {
                if !isSolutionRevealed {
                    if let cell = selectedCell {
                        viewModel.toggleNoteMode(row: cell.row, col: cell.col)
                    }
                }
            }) {
                HStack {
                    Image(systemName: "pencil.circle")
                    Text("Заметка")
                }
            }
            .frame(width: 110, height: 40)
            .background(viewModel.isNoteMode ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }
}

#Preview {
    ContentView()
}
