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
    
    init(authViewModel: AuthViewModel?) {
        self.authViewModel = authViewModel
    }
    
    private func resetGameState() {
        history = []
        isNoteMode = false
        hintsUsed = 0
        incorrectCells.removeAll()
    }
    
    func startGame(difficulty: Difficulty) {
        self.difficulty = difficulty
        resetGameState()
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
    
    private func validateCell(at coordinate: SudokuCoordinate) {
        if grid[coordinate.row][coordinate.col] == solution[coordinate.row][coordinate.col] {
            incorrectCells.remove(coordinate)
        } else {
            incorrectCells.insert(coordinate)
        }
    }
    
    func updateCell(row: Int, col: Int, value: Int) {
        guard isGameStarted, canModifyCell(at: SudokuCoordinate(row: row, col: col)) else { return }
        saveToHistory()
        
        if isNoteMode {
            if notes[row][col].contains(value) {
                notes[row][col].remove(value)
            } else {
                notes[row][col].insert(value)
            }
        } else {
            grid[row][col] = value
            notes[row][col] = []
            validateCell(at: SudokuCoordinate(row: row, col: col))
        }
        
        if isGridFilled() { print("Grid is filled. Finishing game."); finishGame() }
    }
    
    
    func isGridFilled() -> Bool {
        return grid.joined().allSatisfy { $0 != 0 }
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
        incorrectCells = Set(
            zip(grid.indices, grid).flatMap { rowIndex, row in
                zip(row.indices, row).compactMap { colIndex, value in
                    value != solution[rowIndex][colIndex] && value != 0 ? SudokuCoordinate(row: rowIndex, col: colIndex) : nil
                }
            }
        )
        print("Incorrect cells: \(incorrectCells)")
    }
    
    
    func provideHint(for coordinate: SudokuCoordinate?) {
        guard isGameStarted, hintsUsed < 5, let coordinate = coordinate else { return }
        guard canModifyCell(at: coordinate) else { return }
        
        grid[coordinate.row][coordinate.col] = solution[coordinate.row][coordinate.col]
        notes[coordinate.row][coordinate.col] = []
        fixedCells.insert(coordinate)
        incorrectCells.remove(coordinate)
        hintsUsed += 1
        
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
        checkGrid()
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
    
    func clearCell(row: Int, col: Int) {
        guard isGameStarted, canModifyCell(at: SudokuCoordinate(row: row, col: col)) else { return }
        saveToHistory()
        
        grid[row][col] = 0
        notes[row][col].removeAll()
        incorrectCells.remove(SudokuCoordinate(row: row, col: col))
    }
    
    
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
