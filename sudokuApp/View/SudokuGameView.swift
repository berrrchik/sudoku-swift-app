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

struct AlertIdentifier: Identifiable {
    enum Choice {
        case warning, resultCorrect, resultIncorrect
    }

    var id: Choice
}

struct SudokuGameView: View {
    @ObservedObject var authViewModel: AuthViewModel
    let difficulty: Difficulty
    @State private var selectedCell: SudokuCoordinate? = nil
    @State private var isSolutionRevealed = false
    
    @State private var alertIdentifier: AlertIdentifier?
//    @Published var incorrectCells: Set<SudokuCoordinate> = []
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject private var viewModel: SudokuViewModel

    init(difficulty: Difficulty, authViewModel: AuthViewModel) {
        self.difficulty = difficulty
        self.authViewModel = authViewModel
        _viewModel = StateObject(wrappedValue: SudokuViewModel(authViewModel: authViewModel))
    }

    
    var body: some View {
        VStack(spacing: -15) {
            HStack(spacing: 15) {
                
                buttonStyle(systemImage: "arrow.uturn.backward", subtitleKey: "go.back.button.subtitle", background: .blue) {
                    presentationMode.wrappedValue.dismiss()
                }
                Spacer()
                buttonStyle(systemImage: "play", subtitleKey: "start.button.subtitle", background: .green) {
                    isSolutionRevealed = false
                    viewModel.isGameStarted = true
                    viewModel.startGame(difficulty: difficulty)
                }
                
//                buttonStyle(systemImage: "checkmark.circle", subtitleKey: "Проверить", background: .purple) {
//                    viewModel.checkGrid()
//                }
                
                buttonStyle(systemImage: "checkmark", subtitleKey: "answer.button.subtitle", background: .red) {
                    print("Showing warning alert")
                    alertIdentifier = AlertIdentifier(id: .warning)
                }
            }
            
            SudokuGridView(
                grid: $viewModel.grid,
                notes: $viewModel.notes,
                fixedCells: viewModel.fixedCells,
                selectedCell: $selectedCell,
                incorrectCells: viewModel.incorrectCells,
                isGameStarted: viewModel.isGameStarted,
                isSolutionRevealed: isSolutionRevealed
//                isChecked: viewModel.isChecked
            )
            .padding()
            
            numberButtons()
                .padding()
            
            HStack(spacing: 20) {
                
                ZStack {
                    buttonStyle(systemImage: "lightbulb", subtitleKey: "hint.button.subtitle", background: .orange) {
                        viewModel.provideHint(for: selectedCell)
                    }
                    if !isSolutionRevealed {
                        if viewModel.hintsUsed < 5 {
                            Circle()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.red)
                                .overlay(
                                    Text("\(5 - viewModel.hintsUsed)")
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .bold))
                                )
                                .offset(x: 25, y: -30)
                        }
                    }
                }
                
                buttonStyle(systemImage: "trash", subtitleKey: "delete.button.subtitle", background: .black) {
                    if !isSolutionRevealed, let cell = selectedCell {
                        viewModel.clearCell(row: cell.row, col: cell.col)
                    }
                }
                
                buttonStyle(systemImage: "arrow.uturn.backward.circle", subtitleKey: "undo.button.subtitle", background: .pink) {
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
            
        }
        .onAppear {
            viewModel.grid = Array(repeating: Array(repeating: 0, count: 9), count: 9)
//            viewModel.startGame(difficulty: difficulty)
            viewModel.onResultMessageUpdate = { message in
                print("Message received: \(message)")
                DispatchQueue.main.async {
                    print("Updating alertIdentifier to: \(message.contains("правильно") ? "resultCorrect" : "resultIncorrect")")
                    if message.contains("правильно") {
                        print("Correct solution detected")
                        alertIdentifier = AlertIdentifier(id: .resultCorrect)
                    } else {
                        print("Incorrect solution detected")
                        alertIdentifier = AlertIdentifier(id: .resultIncorrect)
                    }
                }
            }
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .alert(item: $alertIdentifier) { alert in
                    switch alert.id {
                    case .warning:
                        return Alert(
                            title: Text("Предупреждение"),
                            message: Text("После просмотра ответа баллы за решение не будут начислены."),
                            primaryButton: .default(Text("Всё-равно посмотреть"), action: {
                                viewModel.fillWithSolution()
                                isSolutionRevealed = true
                                selectedCell = nil
                            }),
                            secondaryButton: .default(Text("Продолжить решать самостоятельно"))
                        )
                    case .resultCorrect:
                        return Alert(
                            title: Text("Результат"),
                            message: Text("Судоку решена правильно! Баллы начислены."),
                            dismissButton: .default(Text("ОК"), action: {
//                                viewModel.startGame(difficulty: difficulty)
                                viewModel.grid = Array(repeating: Array(repeating: 0, count: 9), count: 9)
                            })
                        )
                    case .resultIncorrect:
                        return Alert(
                            title: Text("Результат"),
                            message: Text("Судоку решена неверно!"),
                            primaryButton: .default(Text("Показать ответ"), action: {
                                viewModel.fillWithSolution()
                                isSolutionRevealed = true
                            }),
                            secondaryButton: .default(Text("Продолжить"))
                        )
                    }
                }
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
    SudokuGameView(difficulty: .medium, authViewModel: AuthViewModel())
}
