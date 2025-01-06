import Foundation
import SwiftUI

struct CellView: View {
    let value: Int
    let isFixed: Bool
    let isHighlighted: Bool // Подсвечивание строки, столбца, блока
    let isSelected: Bool // Выбранная ячейка
    let isSameValue: Bool // Подсветка одинаковых значений
    let borderWidths: (top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) // Толщины границ

    var body: some View {
        Text(value == 0 ? "" : "\(value)")
            .font(.system(size: isFixed ? 25 : 23, weight: isFixed ? .bold : .regular))
            .frame(width: 40, height: 40)
            .background(
                isSelected ? Color.blue :
                isSameValue ? Color.blue.opacity(0.7) :
                isHighlighted ? Color.gray.opacity(0.5) :
                Color.white
            )
            .overlay(borderOverlay) // Используем кастомные границы
        
            .foregroundColor(.black)
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
