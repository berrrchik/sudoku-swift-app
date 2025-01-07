import Foundation
import SwiftUI

struct DifficultySelectionView: View {
    let onDifficultySelected: (Difficulty) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Выберите уровень сложности")
                .multilineTextAlignment(.center)
                .font(.title)
                .padding()
            
            difficultyButton(title: "Лёгкий", color: .green, difficulty: .easy)
            difficultyButton(title: "Средний", color: .orange, difficulty: .medium)
            difficultyButton(title: "Тяжёлый", color: .red, difficulty: .hard)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
        .ignoresSafeArea()
    }
    
    private func difficultyButton(title: String, color: Color, difficulty: Difficulty) -> some View {
        Button(title) {
            onDifficultySelected(difficulty)
        }
        .frame(width: 150, height: 80)
        .background(color)
        .foregroundColor(.white)
        .cornerRadius(8)
        .font(.system(size: 25).bold())
    }
}

#Preview {
    DifficultySelectionView(onDifficultySelected: {_ in })
}
