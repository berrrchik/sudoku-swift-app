import Foundation
import SwiftUI

extension View {
    func buttonStyle(systemImage: String? = nil, title: String? = nil, subtitleKey: String? = nil, background: Color, action: @escaping () -> Void) -> some View {
        VStack(spacing: 4) {
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
            
            if let subtitleKey = subtitleKey {
                Text(NSLocalizedString(subtitleKey, comment: ""))
                    .font(.caption)
                    .foregroundColor(.black)
            }
        }
    }
}


struct SudokuGameView: View {
    @StateObject private var authViewModel = AuthViewModel()
    let difficulty: Difficulty
    @StateObject private var viewModel = SudokuViewModel()
    @State private var selectedCell: SudokuCoordinate? = nil
    @State private var resultMessage: String? = nil
    @State private var isSolutionRevealed = false
    let onBack: () -> Void
    
    var body: some View {
        VStack(spacing: -15) {
            HStack(spacing: 20) {
                buttonStyle(systemImage: "arrow.uturn.backward", subtitleKey: "go.back.button.subtitle", background: .blue) {
                    onBack()
                }
                Spacer()
                buttonStyle(systemImage: "play", subtitleKey: "start.button.subtitle", background: .green) {
                    isSolutionRevealed = false
                    viewModel.isGameStarted = true
                    viewModel.startGame(difficulty: difficulty)
                }
                
                buttonStyle(systemImage: "checkmark", subtitleKey: "answer.button.subtitle", background: .red) {
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
                
                buttonStyle(systemImage: "lightbulb", subtitleKey: "hint.button.subtitle", background: .orange) {
                        if !isSolutionRevealed {
                            viewModel.provideHint(for: selectedCell)
                        }
                    }
                    
                    buttonStyle(systemImage: "trash", subtitleKey: "delete.button.subtitle", background: .black) {
                        if !isSolutionRevealed, let cell = selectedCell {
                            viewModel.clearCell(row: cell.row, col: cell.col)
                        }
                    }
                    
                    buttonStyle(systemImage: "arrow.uturn.backward.circle", subtitleKey: "go.back.button.subtitle", background: .pink) {
                        if !isSolutionRevealed {
                            viewModel.undoLastAction()
                        }
                    }
                    
                    buttonStyle(systemImage: "pencil", subtitleKey: "notes.button.subtitle", background: viewModel.isNoteMode ? .blue : .gray) {
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

//extension SudokuGameView {
//    func finishSudoku(isSolved: Bool) {
//        if isSolved {
//            authViewModel.updatePoints(for: difficulty, isSolved: true)
//            showAlert(title: "Congratulations!", message: "You solved the sudoku and earned points.")
//        } else {
//            showAlert(title: "Hint Used", message: "Points are not awarded if the answer is shown.")
//        }
//    }
//    
//    func showAlert(title: String, message: String) {
//        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//           let rootViewController = windowScene.windows.first?.rootViewController {
//            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default))
//            rootViewController.present(alert, animated: true)
//        }
//    }
//}

#Preview {
    SudokuGameView(difficulty: .easy, onBack: {})
}
