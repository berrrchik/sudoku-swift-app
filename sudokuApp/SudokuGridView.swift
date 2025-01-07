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

// Предварительный просмотр
//#Preview {
//    SudokuGridView(
//        grid: .constant(Array(repeating: Array(repeating: 0, count: 9), count: 9)), // Пустая сетка 9x9
//        fixedCells: Set([SudokuCoordinate(row: 0, col: 0), SudokuCoordinate(row: 1, col: 1)]),
//        selectedCell: .constant(nil) // Нет выбранной ячейки
//    )
//}

