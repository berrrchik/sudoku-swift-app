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
    
    @Published var hintsUsed = 0
    var authViewModel: AuthViewModel?
    var difficulty: Difficulty?
    var onResultMessageUpdate: ((String) -> Void)?
    @Published var incorrectCells: Set<SudokuCoordinate> = []
//    @Published var isChecked: Bool = false

    func startGame(difficulty: Difficulty) {
        self.difficulty = difficulty
        history = []
        isNoteMode = false
        isGameStarted = true
        hintsUsed = 0

        let puzzle = SudokuGenerator.generatePuzzle(difficulty: difficulty)
        grid = puzzle.puzzle
        solution = puzzle.solution
        fixedCells = getFixedCells(from: grid)

        print("Puzzle:")
        printGrid(grid)
        print("Solution:")
        printGrid(solution)
    }
    
    private func canModifyCell(at coordinate: SudokuCoordinate) -> Bool {
        return isGameStarted && !fixedCells.contains(coordinate)
    }

    func updateCell(row: Int, col: Int, value: Int) {
        guard isGameStarted else { return }
        print("Updating cell at (\(row), \(col)) with value \(value)")
        let coordinate = SudokuCoordinate(row: row, col: col)
        guard canModifyCell(at: SudokuCoordinate(row: row, col: col)) else { return }
        
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
            
            if value == solution[row][col] {
                incorrectCells.remove(coordinate)
            } else {
                incorrectCells.insert(coordinate)
            }
        }
        
        if isGridFilled() {
            print("Grid is filled. Finishing game.")
            finishGame()
        }
    }

    func isGridFilled() -> Bool {
        return !grid.joined().contains(0)
    }

    func finishGame() {
        guard let difficulty = difficulty else { return }
        print("Finishing game. Checking solution...")
        if isSolutionCorrect() {
            print("Solution is correct!")
            authViewModel?.updatePoints(for: difficulty, isSolved: true)
            onResultMessageUpdate?("Судоку решена правильно! Баллы начислены.")
        } else {
            print("Solution is incorrect!")
            onResultMessageUpdate?("Судоку решена неверно!")
        }
    }

    func checkGrid() {
        guard isGameStarted else { return }
        incorrectCells.removeAll()

        for row in 0..<grid.count {
            for col in 0..<grid[row].count {
                if grid[row][col] != solution[row][col], grid[row][col] != 0 {
                    incorrectCells.insert(SudokuCoordinate(row: row, col: col))
                }
            }
        }
//        isChecked = true
        print("Incorrect cells: \(incorrectCells)")
    }

//    func provideHint(for coordinate: SudokuCoordinate?) {
//        guard isGameStarted, hintsUsed < 5 else { return }
//        hintsUsed += 1
//        guard let coordinate = coordinate, !fixedCells.contains(coordinate) else { return }
//
//        grid[coordinate.row][coordinate.col] = solution[coordinate.row][coordinate.col]
//        notes[coordinate.row][coordinate.col] = []
//        fixedCells.insert(coordinate)
//        incorrectCells.remove(coordinate)
//        
//        if isGridFilled() {
//            print("Grid is filled. Finishing game.")
//            finishGame()
//        }
//        
//    }
    func provideHint(for coordinate: SudokuCoordinate?) {
        guard isGameStarted, hintsUsed < 5, let coordinate = coordinate else { return }
        hintsUsed += 1
        guard canModifyCell(at: coordinate) else { return }
        
        grid[coordinate.row][coordinate.col] = solution[coordinate.row][coordinate.col]
        notes[coordinate.row][coordinate.col] = []
        fixedCells.insert(coordinate)
        incorrectCells.remove(coordinate)
        
        if isGridFilled() {
            print("Grid is filled. Finishing game.")
            finishGame()
        }
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
        incorrectCells.removeAll()
        isNoteMode = false
    }

    func isSolutionCorrect() -> Bool {
        return grid == solution && incorrectCells.isEmpty
    }

//    func clearCell(row: Int, col: Int) {
//        guard isGameStarted else { return }
//        if isNoteMode {
//            saveToHistory()
//            notes[row][col] = []
//        } else {
//            guard !fixedCells.contains(SudokuCoordinate(row: row, col: col)) else { return }
//            saveToHistory()
//            grid[row][col] = 0
//            notes[row][col] = []
//        }
//    }

    func clearCell(row: Int, col: Int) {
        guard isGameStarted else { return }
        let coordinate = SudokuCoordinate(row: row, col: col)
        guard canModifyCell(at: coordinate) else { return }
        
        saveToHistory()
        if isNoteMode {
            notes[row][col] = []
        } else {
            grid[row][col] = 0
            notes[row][col] = []
        }
    }

//    private func saveToHistory() {
//        history.append((grid, notes))
//    }
    
    private func saveToHistory() {
        guard history.last?.0 != grid || history.last?.1 != notes else { return }
        history.append((grid, notes))
    }

    private func getFixedCells(from grid: [[Int]]) -> Set<SudokuCoordinate> {
        return Set(grid.enumerated().flatMap { rowIndex, row in
            row.enumerated().compactMap { colIndex, value in
                value > 0 ? SudokuCoordinate(row: rowIndex, col: colIndex) : nil
            }
        })
    }

    private func printGrid(_ grid: [[Int]]) {
        for row in grid {
            print(row.map { String($0) }.joined(separator: " "))
        }
        print("\n")
    }
    
    func toggleNoteMode(row: Int, col: Int) {
        let coordinate = SudokuCoordinate(row: row, col: col)
        guard canModifyCell(at: coordinate) else { return }

        if !isNoteMode && grid[row][col] != 0 {
            saveToHistory()
            notes[row][col] = [grid[row][col]]
            grid[row][col] = 0
        }
        isNoteMode.toggle()
    }
}
