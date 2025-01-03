//import SwiftUI
//
//struct ContentView: View {
//    @StateObject private var viewModel = SudokuViewModel() // Управляет данными судоку
//    @State private var selectedCell: SudokuCoordinate? = nil // Хранит выбранную ячейку
//    @State private var isGameStarted = false // Отслеживает, нажата ли кнопка "Начать"
//    @State private var resultMessage: String? = nil // Сообщение "Правильно" или "Неправильно"
//
//    var body: some View {
//        VStack {
//            SudokuGridView(
//                grid: $viewModel.grid, // Передаём текущую сетку
//                fixedCells: viewModel.fixedCells, // Фиксированные ячейки
//                selectedCell: $selectedCell // Текущая выбранная ячейка
//            )
//            .padding() // Добавляем отступы
//
//            HStack { // Ряд кнопок с числами от 1 до 9
//                ForEach(1...9, id: \.self) { number in // Проходим по числам
//                    Button("\(number)") { // Создаём кнопку с числом
//                        if let cell = selectedCell { // Если ячейка выбрана
//                            viewModel.updateCell(row: cell.row, col: cell.col, value: number) // Обновляем её
//                        }
//                    }
//                    .frame(width: 35, height: 40) // Размер кнопки
//                    .background(Color.black) // Фон кнопки
//                    .foregroundColor(.white) // Цвет текста
//                    .cornerRadius(8) // Скруглённые края
//                }
//            }
//            .padding()
//
//            HStack {
//                Button("Начать") { // Кнопка "Начать"
//                    isGameStarted = true // Устанавливаем флаг
//                    viewModel.fetchSudoku(difficulty: "easy") // Загружаем судоку
//                }
//                .frame(width: 70, height: 40)
//                .background(Color.green)
//                .foregroundColor(.white)
//                .cornerRadius(8)
//
//                Button("Ответ") { // Кнопка "Ответ"
//                    viewModel.fillWithSolution()
//                }
//                .frame(width: 60, height: 40)
//                .background(Color.red)
//                .foregroundColor(.white)
//                .cornerRadius(8)
//            }
//        }
//        .onAppear {
//            if !isGameStarted {
//                viewModel.grid = Array(repeating: Array(repeating: 0, count: 9), count: 9) // Пустая доска
//            }
//        }
//        .padding() // Общие отступы для всего
//    }
//}
//
//#Preview {
//    ContentView() // Показываем, как выглядит экран
//}

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = SudokuViewModel()
    @State private var selectedCell: SudokuCoordinate? = nil
    @State private var resultMessage: String? = nil // Сообщение "Правильно" или "Неправильно"

    var body: some View {
        VStack {
            SudokuGridView(
                grid: $viewModel.grid,
                fixedCells: viewModel.fixedCells,
                selectedCell: $selectedCell
            )
            .padding()

            HStack {
                ForEach(1...9, id: \.self) { number in
                    Button("\(number)") {
                        if let cell = selectedCell {
                            viewModel.updateCell(row: cell.row, col: cell.col, value: number)
                        }
                    }
                    .frame(width: 35, height: 40)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            .padding()

            HStack {
                Button("Начать") {
                    resultMessage = nil // Сбрасываем сообщение
                    viewModel.fetchSudoku(difficulty: "medium")
                }
                .frame(width: 70, height: 40)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)

                Button("Ответ") {
                    resultMessage = nil // Сбрасываем сообщение
                    viewModel.fillWithSolution()
                }
                .frame(width: 70, height: 40)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)

                Button("Проверить") { // Кнопка "Проверить"
                    if viewModel.isSolutionCorrect() {
                        resultMessage = "Правильно" // Если сетка совпадает с решением
                    } else {
                        resultMessage = "Неправильно" // Если есть расхождения
                    }
                }
                .frame(width: 90, height: 40)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Button("Удалить") { // Кнопка "Проверить"
                    if let cell = selectedCell {
                        viewModel.clearCell(row: cell.row, col: cell.col) // Очищаем значение
                    }
                }
                .frame(width: 90, height: 40)
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding()

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
