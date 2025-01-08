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
    
    func startGame(difficulty: Difficulty) {
        history = []
        isNoteMode = false
        isGameStarted = true

        let puzzle = SudokuGenerator.generatePuzzle(difficulty: difficulty)
        grid = puzzle.puzzle
        solution = puzzle.solution
        fixedCells = getFixedCells(from: grid)

        print("Puzzle:")
        printGrid(grid)
        print("Solution:")
        printGrid(solution)
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

    func provideHint(for coordinate: SudokuCoordinate?) {
        guard isGameStarted else { return }
        guard let coordinate = coordinate, !fixedCells.contains(coordinate) else { return }

        grid[coordinate.row][coordinate.col] = solution[coordinate.row][coordinate.col]
        notes[coordinate.row][coordinate.col] = []
        fixedCells.insert(coordinate)
    }

    func undoLastAction() {
        guard let lastState = history.popLast() else { return }
        grid = lastState.0
        notes = lastState.1

        for coordinate in fixedCells {
            grid[coordinate.row][coordinate.col] = solution[coordinate.row][coordinate.col]
        }
    }

    func fillWithSolution() {
        guard isGameStarted else { return }
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

    private func saveToHistory() {
        history.append((grid, notes))
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

    private func printGrid(_ grid: [[Int]]) {
        for row in grid {
            print(row.map { String($0) }.joined(separator: " "))
        }
        print("\n")
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
}
