import SwiftUI

// Хранит координаты ячейки
struct SudokuCoordinate: Hashable {
    let row: Int
    let col: Int
}

// Отображает всю сетку судоку
struct SudokuGridView: View {
    @Binding var grid: [[Int]] // Массив чисел для отображения судоку
    let fixedCells: Set<SudokuCoordinate> // Фиксированные ячейки
    @Binding var selectedCell: SudokuCoordinate? // Текущая выбранная ячейка

    var body: some View {
        VStack(spacing: 3) { // Столбец строк
            ForEach(0..<9, id: \.self) { row in // Проходим по строкам
                HStack(spacing: 3) { // Строка ячеек
                    ForEach(0..<9, id: \.self) { col in // Проходим по столбцам
                        let coordinate = SudokuCoordinate(row: row, col: col) // Координаты текущей ячейки
                        CellView(
                            value: grid[row][col], // Значение ячейки
                            isFixed: fixedCells.contains(coordinate) // Проверяем, фиксированная ли ячейка
                        )
                        .onTapGesture { // Обрабатываем нажатие
                            selectedCell = coordinate // Сохраняем выбранную ячейку
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2)) // Фон всей сетки
        .cornerRadius(10) // Скругляем края
    }
}

// Отображает одну ячейку
struct CellView: View {
    let value: Int // Значение ячейки
    let isFixed: Bool // Фиксированная ли ячейка

    var body: some View {
        Text(value == 0 ? "" : "\(value)") // Если 0, показываем пустую ячейку
            .frame(width: 35, height: 35) // Размер ячейки
            .background(isFixed ? Color.gray : Color.white) // Фон зависит от состояния
            .foregroundColor(isFixed ? .black : .blue) // Цвет текста
            .border(Color.black, width: 1) // Граница ячейки
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
