import Foundation
import SwiftUI

struct CellView: View {
    let value: Int
    let isFixed: Bool
    let isHighlighted: Bool // Подсвечивание строки, столбца, блока
    let isSelected: Bool // Выбранная ячейка
    let isSameValue: Bool // Подсветка одинаковых значений
    let borderWidths: (top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) // Толщины границ
    let notes: Set<Int> // Заметки для текущей ячейки
    
    var body: some View {
            ZStack {
                Rectangle()
                    .fill(
                        isSelected ? Color.blue :
                        isSameValue ? Color.blue.opacity(0.7) :
                        isHighlighted ? Color.gray.opacity(0.5) :
                        Color.white
                    )
                    .overlay(borderOverlay)

                if value != 0 {
                    Text("\(value)")
                        .font(.system(size: isFixed ? 25 : 23, weight: isFixed ? .bold : .regular))
                        .foregroundColor(.black)
                }

                if !notes.isEmpty && !isFixed {
                    VStack(spacing: 2.5) {
                        ForEach(1...3, id: \.self) { row in
                            HStack(spacing: 2.5) {
                                ForEach(1...3, id: \.self) { col in
                                    let note = (row - 1) * 3 + col
                                    Text(notes.contains(note) ? "\(note)" : "")
                                        .foregroundStyle(.black)
                                        .font(.system(size: 8))
                                        .frame(width: 10, height: 10)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
            }
            .frame(width: 40, height: 40)
        }

    
    private var borderOverlay: some View {
        GeometryReader { geometry in
            let topBorder = Rectangle()
                .frame(height: borderWidths.top)
                .position(x: geometry.size.width / 2, y: borderWidths.top / 2)
                .foregroundColor(.black)

            let bottomBorder = Rectangle()
                .frame(height: borderWidths.bottom)
                .position(x: geometry.size.width / 2, y: geometry.size.height - borderWidths.bottom / 2)
                .foregroundColor(.black)

            let leftBorder = Rectangle()
                .frame(width: borderWidths.left)
                .position(x: borderWidths.left / 2, y: geometry.size.height / 2)
                .foregroundColor(.black)

            let rightBorder = Rectangle()
                .frame(width: borderWidths.right)
                .position(x: geometry.size.width - borderWidths.right / 2, y: geometry.size.height / 2)
                .foregroundColor(.black)

            return ZStack {
                topBorder
                bottomBorder
                leftBorder
                rightBorder
            }
        }
        .clipped()
    }

}
