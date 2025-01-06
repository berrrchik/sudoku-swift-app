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
    
    private var history: [([[Int]], [[Set<Int>]])] = [] // История сетки и заметок

    @Published var isNoteMode: Bool = false // Режим заметок
    
    @Published var notes: [[Set<Int>]] = Array(repeating: Array(repeating: Set<Int>(), count: 9), count: 9) // Инициализация заметок

    // Загрузка судоку с сервера
    func fetchSudoku(difficulty: String = "medium") {
        history = []
        isNoteMode = false
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
    
    func updateCell(row: Int, col: Int, value: Int) {
        let coordinate = SudokuCoordinate(row: row, col: col)
        guard !fixedCells.contains(coordinate) else { return } // Проверяем, что ячейка не фиксированная

        if isNoteMode {
            // Работа с заметками
            if notes[row][col].contains(value) {
                notes[row][col].remove(value) // Удаляем заметку
            } else {
                saveToHistory() // Сохраняем перед добавлением заметки
                notes[row][col].insert(value) // Добавляем заметку
            }
        } else {
            saveToHistory()
            grid[row][col] = value
            notes[row][col] = [] // Очищаем заметки при вводе значения
        }
    }
    
    func undoLastAction() {
        guard let lastState = history.popLast() else { return }
        grid = lastState.0
        notes = lastState.1

        // Фиксированные ячейки остаются неизменными
        fixedCells.forEach { coordinate in
            grid[coordinate.row][coordinate.col] = solution[coordinate.row][coordinate.col]
        }
    }
    
    func toggleNoteMode(row: Int, col: Int) {
        let coordinate = SudokuCoordinate(row: row, col: col)
        guard !fixedCells.contains(coordinate) else { return } // Проверяем, что ячейка не фиксированная

        if !isNoteMode && grid[row][col] != 0 {
            saveToHistory()
            notes[row][col] = [grid[row][col]] // Переносим значение в заметки
            grid[row][col] = 0 // Очищаем значение
        }
        isNoteMode.toggle()
    }


    private func saveToHistory() {
        // Сохраняем только состояние обычных ячеек
        let editableGrid = grid
        let editableNotes = notes

        history.append((editableGrid, editableNotes))
    }
    
    func provideHint(for coordinate: SudokuCoordinate?) {
        guard let coordinate = coordinate, !fixedCells.contains(coordinate) else { return } // Проверяем, что ячейка выбрана и не фиксированная

        // Устанавливаем правильное значение из решения
        grid[coordinate.row][coordinate.col] = solution[coordinate.row][coordinate.col]

        // Очищаем заметки для этой ячейки
        notes[coordinate.row][coordinate.col] = []

        // Добавляем ячейку в фиксированные
        fixedCells.insert(coordinate)
    }
    
    func fillWithSolution() {
        saveToHistory() // Сохраняем текущее состояние перед изменением
        grid = solution // Заполняем сетку решением
        notes = Array(repeating: Array(repeating: Set<Int>(), count: 9), count: 9) // Очищаем все заметки
        isNoteMode = false // Сбрасываем режим заметок
    }
    
    func isSolutionCorrect() -> Bool {
        return grid == solution
    }
    
    func clearCell(row: Int, col: Int) {
            if isNoteMode {
                saveToHistory() // Сохраняем перед очисткой заметок
                notes[row][col] = []
            } else {
                guard !fixedCells.contains(SudokuCoordinate(row: row, col: col)) else { return }
                saveToHistory()
                grid[row][col] = 0
                notes[row][col] = [] // Очищаем заметки при удалении значения
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
