import Foundation
import SwiftUI

struct DifficultySelectionView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var showProfile = false
    let onDifficultySelected: (Difficulty) -> Void
    
    var body: some View {
        VStack {
            HStack {
                Text("Привет, \(authViewModel.currentUser?.email ?? "Пользователь")")
                    .font(.headline)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.leading)
                
                Spacer()
                
                Button("Профиль") {
                    showProfile = true
                }
                .foregroundColor(.blue)
                .padding(.trailing)
            }

            .padding(.vertical) 
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
            
            Spacer()
            
            VStack(spacing: 20) {
                Text(NSLocalizedString("choose.level", comment: "Choose difficulty level"))
                    .multilineTextAlignment(.center)
                    .font(.title)
                    .padding()
                
                difficultyButton(titleKey: "easy.level", color: .green, difficulty: .easy)
                difficultyButton(titleKey: "medium.level", color: .orange, difficulty: .medium)
                difficultyButton(titleKey: "hard.level", color: .red, difficulty: .hard)
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
        }
        .padding()
        .fullScreenCover(isPresented: $showProfile) {
            ProfileView(authViewModel: authViewModel)
        }
        .onAppear {
            if authViewModel.currentUser == nil {
                authViewModel.checkCurrentUser()
            }
        }
    }
    
    private func difficultyButton(titleKey: String, color: Color, difficulty: Difficulty) -> some View {
        Button(NSLocalizedString(titleKey, comment: "Difficulty level")) {
            onDifficultySelected(difficulty)
        }
        .frame(width: 150, height: 80)
        .background(color)
        .foregroundColor(.white)
        .cornerRadius(8)
        .font(.system(size: 25).bold())
    }
}


//#Preview {
//    DifficultySelectionView(authViewModel: AuthViewModel(), onDifficultySelected: {_ in })
//}

#Preview {
    let mockAuthViewModel = AuthViewModel()
    mockAuthViewModel.currentUser = UserModel(
        id: "12345",
        email: "test@example.com",
        totalPoints: 100,
        easySudokuSolved: 5,
        mediumSudokuSolved: 3,
        hardSudokuSolved: 2,
        easyPoints: 50,
        mediumPoints: 60,
        hardPoints: 90
    )
    return DifficultySelectionView(authViewModel: mockAuthViewModel, onDifficultySelected: {_ in })
}
