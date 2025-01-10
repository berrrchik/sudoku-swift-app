import SwiftUI

struct SudokuCoordinate: Hashable {
    let row: Int
    let col: Int
}

struct SudokuGridView: View {
    @Binding var grid: [[Int]]
    @Binding var notes: [[Set<Int>]]
    let fixedCells: Set<SudokuCoordinate>
    @Binding var selectedCell: SudokuCoordinate?
    let incorrectCells: Set<SudokuCoordinate> // Новое свойство
//    let isChecked: Bool

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<9, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<9, id: \.self) { col in
                        let coordinate = SudokuCoordinate(row: row, col: col)
                        CellView(
                            value: grid[row][col],
                            isFixed: fixedCells.contains(coordinate),
                            isHighlighted: isCellHighlighted(coordinate),
                            isSelected: selectedCell == coordinate,
                            isSameValue: isSameValueHighlighted(coordinate),
                            isIncorrect: incorrectCells.contains(coordinate),
//                            isChecked: isChecked,
                            borderWidths: getBorderWidths(row: row, col: col),
                            notes: notes[row][col]
                        )
                        .onTapGesture { selectedCell = coordinate }
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }

    private func isCellHighlighted(_ coordinate: SudokuCoordinate) -> Bool {
        guard let selected = selectedCell else { return false }
        return selected.row == coordinate.row || selected.col == coordinate.col ||
            (selected.row / 3 == coordinate.row / 3 && selected.col / 3 == coordinate.col / 3)
    }

    private func isSameValueHighlighted(_ coordinate: SudokuCoordinate) -> Bool {
        guard let selected = selectedCell, grid[selected.row][selected.col] != 0 else { return false }
        return grid[coordinate.row][coordinate.col] == grid[selected.row][selected.col]
    }

    private func getBorderWidths(row: Int, col: Int) -> (top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
        (
            top: row % 3 == 0 ? 3.0 : 0.5,
            left: col % 3 == 0 ? 3.0 : 0.5,
            bottom: row == 8 ? 3.0 : 0.5,
            right: col == 8 ? 3.0 : 0.5
        )
    }
}


#Preview {
    SudokuGridView(
        grid: .constant([
            [5, 3, 0, 0, 7, 0, 0, 0, 0],
            [6, 0, 0, 1, 9, 5, 0, 0, 0],
            [0, 9, 8, 0, 0, 0, 0, 6, 0],
            [8, 0, 0, 0, 6, 0, 0, 0, 3],
            [4, 0, 0, 8, 0, 3, 0, 0, 1],
            [7, 0, 0, 0, 2, 0, 0, 0, 6],
            [0, 6, 0, 0, 0, 0, 2, 8, 0],
            [0, 0, 0, 4, 1, 9, 0, 0, 5],
            [0, 0, 0, 0, 8, 0, 0, 7, 9]
        ]),
        notes: .constant(Array(repeating: Array(repeating: Set<Int>(), count: 9), count: 9)),
        fixedCells: Set([
            SudokuCoordinate(row: 0, col: 0),
            SudokuCoordinate(row: 0, col: 1),
            SudokuCoordinate(row: 0, col: 4),
            SudokuCoordinate(row: 1, col: 0),
            SudokuCoordinate(row: 1, col: 3),
            SudokuCoordinate(row: 1, col: 4),
            SudokuCoordinate(row: 1, col: 5)
        ]),
        selectedCell: .constant(SudokuCoordinate(row: 3, col: 4)),
        incorrectCells: Set([SudokuCoordinate(row: 3, col: 4)])
//        isChecked: true
    )
}
