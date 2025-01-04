import SwiftUI

// Хранит координаты ячейки
struct SudokuCoordinate: Hashable {
    let row: Int
    let col: Int
}

struct SudokuGridView: View {
    @Binding var grid: [[Int]]
    let fixedCells: Set<SudokuCoordinate>
    @Binding var selectedCell: SudokuCoordinate?

    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<9, id: \.self) { row in
                HStack(spacing: 2) {
                    ForEach(0..<9, id: \.self) { col in
                        let coordinate = SudokuCoordinate(row: row, col: col)
                        CellView(
                            value: grid[row][col],
                            isFixed: fixedCells.contains(coordinate),
                            isHighlighted: isCellHighlighted(coordinate: coordinate), // Подсветка
                            isSelected: selectedCell == coordinate, // Текущая ячейка
                            isSameValue: isSameValueHighlighted(coordinate: coordinate) // Подсветка одинаковых значений
                        )
                        .onTapGesture {
                            selectedCell = coordinate
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
    }

    // Проверяет, нужно ли подсвечивать ячейку
    private func isCellHighlighted(coordinate: SudokuCoordinate) -> Bool {
        guard let selected = selectedCell else { return false }
        // Подсвечиваем строку, столбец или блок 3x3
        let sameRow = selected.row == coordinate.row
        let sameCol = selected.col == coordinate.col
        let sameBlock = (selected.row / 3 == coordinate.row / 3) &&
                        (selected.col / 3 == coordinate.col / 3)
        return sameRow || sameCol || sameBlock
    }

    // Проверяет, совпадает ли значение в ячейке с выбранной
    private func isSameValueHighlighted(coordinate: SudokuCoordinate) -> Bool {
        guard let selected = selectedCell else { return false }
        let selectedValue = grid[selected.row][selected.col]
        return selectedValue != 0 && grid[coordinate.row][coordinate.col] == selectedValue
    }
}

struct CellView: View {
    let value: Int
    let isFixed: Bool
    let isHighlighted: Bool // Подсвечивание строки, столбца, блока
    let isSelected: Bool // Выбранная ячейка
    let isSameValue: Bool // Подсветка одинаковых значений

    var body: some View {
        Text(value == 0 ? "" : "\(value)")
            .frame(width: 40, height: 40)
            .background(
                isSelected ? Color.blue :
                isSameValue ? Color.blue.opacity(0.7) :
                isHighlighted ? Color.gray.opacity(0.5) :
                Color.white
            )
            .foregroundColor(.black)
            .border(Color.black, width: 1)
    }
}



// Предварительный просмотр
#Preview {
    SudokuGridView(
        grid: .constant(Array(repeating: Array(repeating: 0, count: 9), count: 9)), // Пустая сетка 9x9
        fixedCells: [SudokuCoordinate(row: 0, col: 0), SudokuCoordinate(row: 1, col: 1)], // Пара фиксированных ячеек
        selectedCell: .constant(nil) // Нет выбранной ячейки
    )
}

