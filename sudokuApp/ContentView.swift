import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = SudokuViewModel()
    @State private var selectedCell: SudokuCoordinate? = nil
    @State private var resultMessage: String? = nil // Сообщение "Правильно" или "Неправильно"
    @State private var isSolutionRevealed = false // Флаг, указывающий, что ответ показан
    @State private var timer: Timer? = nil // Хранение таймера

    var body: some View {
        VStack(spacing: -3) {
            SudokuGridView(
                grid: $viewModel.grid,
                fixedCells: viewModel.fixedCells,
                selectedCell: $selectedCell
            )
            .padding()

            VStack(spacing: 4) { // Вертикальный стек для строк
                ForEach(0..<3, id: \.self) { row in // Проходим по строкам
                    HStack(spacing: 4) { // Горизонтальный стек для кнопок в строке
                        ForEach(1...3, id: \.self) { col in // Проходим по столбцам
                            let number = row * 3 + col // Вычисляем число для кнопки
                            Button("\(number)") {
                                if !isSolutionRevealed, let cell = selectedCell { // Блокируем изменение
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
                    resultMessage = nil // Сбрасываем сообщение
                    isSolutionRevealed = false // Сбрасываем флаг
                    viewModel.fetchSudoku(difficulty: "medium")
                }
                .frame(width: 70, height: 40)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)

                Button("Ответ") {
                    resultMessage = nil // Сбрасываем сообщение
                    isSolutionRevealed = true // Устанавливаем флаг, что ответ показан
                    viewModel.fillWithSolution()
                }
                .frame(width: 70, height: 40)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)

                Button("Проверить") { // Кнопка "Проверить"
                    if !isSolutionRevealed {
                        if viewModel.isSolutionCorrect() {
                            resultMessage = "Правильно" // Если сетка совпадает с решением
                        } else {
                            resultMessage = "Неправильно" // Если есть расхождения
                        }
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
                
                Button("Удалить") { // Кнопка "Проверить"
                    if !isSolutionRevealed, let cell = selectedCell { // Проверяем, что ответ не показан
                        viewModel.clearCell(row: cell.row, col: cell.col)
                    }
                }
                .frame(width: 90, height: 40)
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Button("Назад") {
                }
                .frame(width: 90, height: 40)
                .background(Color.pink)
                .foregroundColor(.white)
                .cornerRadius(8)
                
            }
            
            if let message = resultMessage { // Показываем результат
                Text(message)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(message == "Правильно" ? .green : .red)
            }
        }
        .onAppear {
            viewModel.grid = Array(repeating: Array(repeating: 0, count: 9), count: 9) // Пустая доска
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
