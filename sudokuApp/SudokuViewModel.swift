import Foundation
import SwiftUI

class SudokuViewModel: ObservableObject {
    // Храним текущую сетку судоку (9x9)
    @Published var grid: [[Int]] = Array(repeating: Array(repeating: 0, count: 9), count: 9)

    // Храним фиксированные ячейки, которые нельзя менять
    @Published var fixedCells: Set<SudokuCoordinate> = []

    // Показывает, идет ли загрузка данных
    @Published var isLoading: Bool = false

    private var solution: [[Int]] = [] // Хранит правильное решение
    
    private var history: [[[Int]]] = [] // История состояний сетки
    
    // Загрузка судоку с сервера
    func fetchSudoku(difficulty: String = "medium") {
        history = []
        // Формируем URL запроса
        let urlString = "https://sudoku-api.vercel.app/api/dosuku?difficulty=\(difficulty)"
        guard let url = URL(string: urlString) else {
            print("Неверный URL") // Если URL невалидный, выводим ошибку
            return
        }

        // Устанавливаем флаг загрузки
        isLoading = true

        // Отправляем сетевой запрос
        URLSession.shared.dataTask(with: url) { data, _, error in
            // Отключаем флаг загрузки на главном потоке
            DispatchQueue.main.async {
                self.isLoading = false
            }

            // Если есть ошибка, выводим ее
            if let error = error {
                print("Ошибка загрузки: \(error.localizedDescription)")
                return
            }

            // Если данных нет, выводим сообщение
            guard let data = data else {
                print("Нет данных от сервера")
                return
            }

            // Пытаемся декодировать JSON
            do {
                let sudoku = try JSONDecoder().decode(SudokuModel.self, from: data)
                if let firstGrid = sudoku.newboard.grids.first {
                    // Обновляем сетку и фиксированные ячейки
                    DispatchQueue.main.async {
                        self.grid = firstGrid.value
                        self.solution = firstGrid.solution // Сохраняем решение
                        self.fixedCells = self.getFixedCells(from: firstGrid.value)
                        // Выводим в консоль начальную сетку и решение
                        print("Value:")
                        self.printGrid(self.grid)
                        print("Solution:")
                        self.printGrid(self.solution)
                    }
                }
            } catch {
                print("Ошибка парсинга данных: \(error.localizedDescription)")
            }
        }.resume() // Запускаем задачу
    }

    // Функция для обновления значения в ячейке
    func updateCell(row: Int, col: Int, value: Int) {
        // Проверяем, что ячейка не фиксированная
        if fixedCells.contains(SudokuCoordinate(row: row, col: col)) {
            return
        }
        saveToHistory()
        // Если ячейка не фиксированная, обновляем значение
        grid[row][col] = value
    }
    
    // Сохранение текущего состояния в историю
        private func saveToHistory() {
            history.append(grid) // Добавляем текущее состояние сетки в массив истории
        }

        // Отмена последнего действия
        func undoLastAction() {
            guard !history.isEmpty else { return } // Проверяем, есть ли история
            grid = history.removeLast() // Восстанавливаем последнее состояние и удаляем его из истории
        }
    
    func provideHint(for coordinate: SudokuCoordinate?) {
            // Проверяем, что ячейка выбрана и не является фиксированной
            guard let coordinate = coordinate,
                  !fixedCells.contains(coordinate) else { return }
            // Устанавливаем правильное значение из `solution`
            grid[coordinate.row][coordinate.col] = solution[coordinate.row][coordinate.col]
        }
    
    func fillWithSolution() {
            // Заполняем сетку решением
            grid = solution
        }
    
    func isSolutionCorrect() -> Bool {
        return grid == solution
    }
    
    func clearCell(row: Int, col: Int) {
            // Если ячейка не фиксированная, очищаем её
            if !fixedCells.contains(SudokuCoordinate(row: row, col: col)) {
                grid[row][col] = 0
            }
        }

    // Вычисляет фиксированные ячейки (ячейки, которые не равны 0)
    private func getFixedCells(from grid: [[Int]]) -> Set<SudokuCoordinate> {
        var cells = Set<SudokuCoordinate>()
        for (rowIndex, row) in grid.enumerated() {
            for (colIndex, value) in row.enumerated() {
                if value > 0 {
                    cells.insert(SudokuCoordinate(row: rowIndex, col: colIndex))
                }
            }
        }
        return cells
    }
    
    private func printGrid(_ grid: [[Int]]) {
            for row in grid {
                print(row.map { String($0) }.joined(separator: " "))
            }
            print("\n") // Пустая строка для разделения
        }
}
