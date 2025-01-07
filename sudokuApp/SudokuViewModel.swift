import Foundation
import SwiftUI

class SudokuViewModel: ObservableObject {
    @Published var isGameStarted: Bool = false
    @Published var grid: [[Int]] = Array(repeating: Array(repeating: 0, count: 9), count: 9)
    @Published var notes: [[Set<Int>]] = Array(repeating: Array(repeating: Set<Int>(), count: 9), count: 9)
    @Published var isNoteMode: Bool = false
    @Published var fixedCells: Set<SudokuCoordinate> = []
    private var solution: [[Int]] = []
    private var history: [([[Int]], [[Set<Int>]])] = []

    func fetchSudoku(difficulty: String = "medium") {
        history = []
        isNoteMode = false
        isGameStarted = true
        let urlString = "https://sudoku-api.vercel.app/api/dosuku?difficulty=\(difficulty)"
        guard let url = URL(string: urlString) else {
            print("Неверный URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            
            if let error = error {
                print("Ошибка загрузки: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("Нет данных от сервера")
                return
            }

            do {
                let sudoku = try JSONDecoder().decode(SudokuModel.self, from: data)
                if let firstGrid = sudoku.newboard.grids.first {
                    DispatchQueue.main.async {
                        self.grid = firstGrid.value
                        self.solution = firstGrid.solution
                        self.fixedCells = self.getFixedCells(from: firstGrid.value)
                        print("Value:")
                        self.printGrid(self.grid)
                        print("Solution:")
                        self.printGrid(self.solution)
                    }
                }
            } catch {
                print("Ошибка парсинга данных: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func updateCell(row: Int, col: Int, value: Int) {
        guard isGameStarted else { return }
        let coordinate = SudokuCoordinate(row: row, col: col)
        guard !fixedCells.contains(coordinate) else { return }

        if isNoteMode {
            if notes[row][col].contains(value) {
                notes[row][col].remove(value)
            } else {
                saveToHistory()
                notes[row][col].insert(value)
            }
        } else {
            saveToHistory()
            grid[row][col] = value
            notes[row][col] = []
        }
    }
    
    func undoLastAction() {
        guard let lastState = history.popLast() else { return }
        grid = lastState.0
        notes = lastState.1

        fixedCells.forEach { coordinate in
            grid[coordinate.row][coordinate.col] = solution[coordinate.row][coordinate.col]
        }
    }
    
    func toggleNoteMode(row: Int, col: Int) {
        let coordinate = SudokuCoordinate(row: row, col: col)
        guard !fixedCells.contains(coordinate) else { return }

        if !isNoteMode && grid[row][col] != 0 {
            saveToHistory()
            notes[row][col] = [grid[row][col]]
            grid[row][col] = 0
        }
        isNoteMode.toggle()
    }


    private func saveToHistory() {
        let editableGrid = grid
        let editableNotes = notes

        history.append((editableGrid, editableNotes))
    }
    
    func provideHint(for coordinate: SudokuCoordinate?) {
        guard let coordinate = coordinate, !fixedCells.contains(coordinate) else { return }
        grid[coordinate.row][coordinate.col] = solution[coordinate.row][coordinate.col]
        notes[coordinate.row][coordinate.col] = []
        fixedCells.insert(coordinate)
    }
    
    func fillWithSolution() {
//        saveToHistory()
        grid = solution
        notes = Array(repeating: Array(repeating: Set<Int>(), count: 9), count: 9)
        isNoteMode = false
    }
    
    func isSolutionCorrect() -> Bool {
        return grid == solution
    }
    
    func clearCell(row: Int, col: Int) {
        guard isGameStarted else { return }
            if isNoteMode {
                saveToHistory()
                notes[row][col] = []
            } else {
                guard !fixedCells.contains(SudokuCoordinate(row: row, col: col)) else { return }
                saveToHistory()
                grid[row][col] = 0
                notes[row][col] = []
            }
        }

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
    
    private func printGrid(_ grid: [[Int]]) { //выводит в консоль судоку и решение
            for row in grid {
                print(row.map { String($0) }.joined(separator: " "))
            }
            print("\n")
        }
}
