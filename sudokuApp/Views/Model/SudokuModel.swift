import Foundation

struct SudokuPuzzle {
    let puzzle: [[Int]]
    let solution: [[Int]]
}

struct SudokuCoordinate: Hashable {
    let row: Int
    let col: Int
}

struct SudokuState {
    let grid: [[Int]]
    let notes: [[Set<Int>]]
}
