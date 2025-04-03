import Foundation
import SwiftUI

extension View {
    func customButtonStyle(systemImage: String? = nil, title: String? = nil, subtitleKey: String? = nil, action: @escaping () -> Void) -> some View {
        VStack(spacing: 4) {
            Button(action: action) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 55, height: 55)
                    
                    VStack {
                        if let systemImage = systemImage {
                            Image(systemName: systemImage)
                                .font(.system(size: 35))
                                .foregroundColor(.blue)
                        }
                        if let title = title {
                            Text(title)
                                .font(.system(size: 35))
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            
            if let subtitleKey = subtitleKey {
                Text(NSLocalizedString(subtitleKey, comment: ""))
                    .font(.caption)
                    .foregroundColor(Color.black.opacity(0.8))
            }
        }
    }
}

struct AlertIdentifier: Identifiable {
    enum Choice {
        case warning, resultCorrect
    }
    var id: Choice
}

struct SudokuGameView: View {
    @ObservedObject var authViewModel: AuthViewModel
    let difficulty: Difficulty
    @State private var selectedCell: SudokuCoordinate? = nil
    @State private var isSolutionRevealed = false
    
    @State private var alertIdentifier: AlertIdentifier?
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject private var viewModel: SudokuViewModel
    
    init(difficulty: Difficulty, authViewModel: AuthViewModel) {
        self.difficulty = difficulty
        self.authViewModel = authViewModel
        _viewModel = StateObject(wrappedValue: SudokuViewModel(authViewModel: authViewModel))
    }
    
    
    var body: some View {
        VStack(spacing: 0) {
            topPanel
            
            SudokuGridView(
                grid: $viewModel.grid,
                notes: $viewModel.notes,
                fixedCells: viewModel.fixedCells,
                selectedCell: Binding(
                    get: { viewModel.isGameStarted && !isSolutionRevealed ? selectedCell : nil },
                    set: { newValue in if viewModel.isGameStarted && !isSolutionRevealed { selectedCell = newValue } }
                ),
                incorrectCells: viewModel.incorrectCells,
                isGameStarted: viewModel.isGameStarted,
                isSolutionRevealed: isSolutionRevealed
            )
            .padding()
            
            numberButtons()
                .padding()
            
            bottomPanel
            
        }
        .onAppear {
            viewModel.grid = Array(repeating: Array(repeating: 0, count: 9), count: 9)
            viewModel.onResultMessageUpdate = { message in
                print("Message received: \(message)")
                DispatchQueue.main.async {
                    print("Updating alertIdentifier to: \(message.contains("правильно") ? "resultCorrect" : "resultIncorrect")")
                    if message.contains("правильно") || message.contains("correct") {
                        print("Correct solution detected")
                        alertIdentifier = AlertIdentifier(id: .resultCorrect)
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
                    title: Text(NSLocalizedString("warning.title", comment: "Title for the warning alert")),
                    message: Text(NSLocalizedString("warning.message", comment: "Message for the warning alert")),
                    primaryButton: .default(Text(NSLocalizedString("warning.primaryButton", comment: "Primary button for the warning alert")), action: {
                        viewModel.fillWithSolution()
                        isSolutionRevealed = true
                        selectedCell = nil
                    }),
                    secondaryButton: .default(Text(NSLocalizedString("warning.secondaryButton", comment: "Secondary button for the warning alert")))
                )
            case .resultCorrect:
                return Alert(
                    title: Text(NSLocalizedString("resultCorrect.title", comment: "Title for the correct result alert")),
                    message: Text(NSLocalizedString("resultCorrect.message", comment: "Message for the correct result alert")),
                    dismissButton: .default(Text(NSLocalizedString("resultCorrect.dismissButton", comment: "Dismiss button for the correct result alert")), action: {
                        viewModel.grid = Array(repeating: Array(repeating: 0, count: 9), count: 9)
                    })
                )
            }
        }
    }
    
    private func numberButtons() -> some View {
        VStack(spacing: 10) {
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(1...3, id: \.self) { col in
                        let number = row * 3 + col
                        Color.clear
                            .customButtonStyle(title: "\(number)") {
                                if !isSolutionRevealed, let cell = selectedCell {
                                    viewModel.updateCell(row: cell.row, col: cell.col, value: number)
                                }
                            }
                    }
                }
            }
        }
    }
    
    private var topPanel: some View {
        HStack() {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text(NSLocalizedString("back.button", comment: "Button to go back to the previous screen"))
                }
                .foregroundColor(.blue)
                .font(.system(size: 20, weight: .medium))
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                Button(action: {
                    isSolutionRevealed = false
                    viewModel.isGameStarted = true
                    selectedCell = nil
                    viewModel.startGame(difficulty: difficulty)
                }) {
                    Text(NSLocalizedString("start.button", comment: "Button to start the game"))
                        .foregroundColor(.blue)
                        .font(.system(size: 20, weight: .medium))
                }
                
                Button(action: {
                    print("Showing warning alert")
                    alertIdentifier = AlertIdentifier(id: .warning)
                }) {
                    Text(NSLocalizedString("answer.button", comment: "Button to view the solution"))
                        .foregroundColor(.blue)
                        .font(.system(size: 20, weight: .medium))
                }
            }
        }
    }
    
    private var bottomPanel: some View {
        HStack(spacing: 30) {
            ZStack {
                customButtonStyle(systemImage: "lightbulb", subtitleKey: "hint.button.subtitle") {
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
                            .offset(x: 25, y: -32)
                    }
                }
            }
            
            customButtonStyle(systemImage: "trash", subtitleKey: "delete.button.subtitle") {
                if !isSolutionRevealed, let cell = selectedCell {
                    viewModel.clearCell(row: cell.row, col: cell.col)
                }
            }
            
            customButtonStyle(systemImage: "arrow.uturn.backward.circle", subtitleKey: "undo.button.subtitle") {
                if !isSolutionRevealed {
                    viewModel.undoLastAction()
                }
            }
            
            customButtonStyle(systemImage: "pencil", subtitleKey: "notes.button.subtitle") {
                if !isSolutionRevealed {
                    if let cell = selectedCell {
                        viewModel.toggleNoteMode(row: cell.row, col: cell.col)
                    }
                }
            }
            .overlay(
                Circle()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.blue)
                    .overlay(
                        Text(viewModel.isNoteMode ? "On" : "Off")
                            .foregroundColor(.white)
                            .font(.system(size: 12, weight: .bold))
                    )
                    .offset(x: 25, y: -32)
            )
        }
        .padding()
    }
    
}

#Preview {
    SudokuGameView(difficulty: .easy, authViewModel: AuthViewModel())
}
