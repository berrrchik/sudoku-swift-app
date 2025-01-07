import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = SudokuViewModel()
    @State private var selectedCell: SudokuCoordinate? = nil
    @State private var resultMessage: String? = nil
    @State private var isSolutionRevealed = false

    var body: some View {
        VStack(spacing: -3) {
            SudokuGridView(
                grid: $viewModel.grid,
                notes: $viewModel.notes,
                fixedCells: viewModel.fixedCells,
                selectedCell: $selectedCell
            )
            .padding()

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
            .padding()

            HStack {
                Button("Начать") {
                    isSolutionRevealed = false
                    viewModel.isGameStarted = true
                    viewModel.fetchSudoku(difficulty: "medium")
                }
                .frame(width: 70, height: 40)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)

                Button("Ответ") {
                    isSolutionRevealed = true
                    viewModel.fillWithSolution()
                }
                .frame(width: 70, height: 40)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)

                Button("Проверить") {
                    if !isSolutionRevealed {
                        if viewModel.isSolutionCorrect() {
                            resultMessage = "Правильно"
                        } else {
                            resultMessage = "Неправильно"
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                resultMessage = nil
                            }
                }
                .frame(width: 90, height: 40)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Button("Подсказка") {
                    if !isSolutionRevealed {
                        viewModel.provideHint(for: selectedCell)
                    } else {
                        return
                    }
                }
                .frame(width: 90, height: 40)
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(8)
                
            }
            .padding()

            HStack {
                
                Button("Удалить") {
                    if !isSolutionRevealed, let cell = selectedCell {
                        viewModel.clearCell(row: cell.row, col: cell.col)
                    }
                }
                .frame(width: 90, height: 40)
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Button("Назад") {
                    if !isSolutionRevealed {
                        viewModel.undoLastAction()
                    }
                }
                .frame(width: 90, height: 40)
                .background(Color.pink)
                .foregroundColor(.white)
                .cornerRadius(8)
                
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
                        .frame(width: 110, height: 40)
                        .background(viewModel.isNoteMode ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                
            }
            
            if let message = resultMessage {
                Text(message)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(message == "Правильно" ? .green : .red)
            }
        }
        .onAppear {
            viewModel.grid = Array(repeating: Array(repeating: 0, count: 9), count: 9)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
