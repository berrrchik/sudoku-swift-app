import Foundation
import SwiftUI

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
            .font(
                isFixed ? .system(size: 25) : .system(size: 23)
            )
            .bold(
                isFixed == true
            )
    }
}
