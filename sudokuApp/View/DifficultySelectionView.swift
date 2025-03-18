import Foundation
import SwiftUI

struct DifficultySelectionView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var showProfile = false
    let onDifficultySelected: (Difficulty) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Привет, \(authViewModel.currentUser?.email ?? "Игрок")")
                    .font(.system(size: 18, weight: .medium))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.leading)
                
                Spacer()
                
                Button {
                    showProfile = true
                } label: {
                    HStack(spacing: 4) {
                        Text("Профиль")
                            .font(.system(size: 18, weight: .medium))
                        Image(systemName: "person.circle")
                            .font(.system(size: 20))
                    }
                    .foregroundColor(.blue)
                }
                .padding(.trailing)
                
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.1))
                        
            VStack(spacing: 40) {
                
                VStack(spacing: 8) {
                    Text("Судоку")
                        .font(.system(size: 40, weight: .bold))
                    Text(NSLocalizedString("choose.level", comment: "Choose difficulty level"))
                        .font(.system(size: 22))
                        .foregroundColor(.gray)
                }
                .padding(.top, 60)
                
                VStack(spacing: 20) {
                        difficultyButton(
                            titleKey: "easy.level",
                            subtitle: "Для начинающих",
                            color: .green, 
                            difficulty: .easy
                        )
                    
                    difficultyButton(
                        titleKey: "medium.level",
                        subtitle: "Для опытных",
                        color: .orange,
                        difficulty: .easy
                    )
                    
                    difficultyButton(
                        titleKey: "hard.level",
                        subtitle: "Для экспертов",
                        color: .red,
                        difficulty: .easy
                    )
                }
            }
            .padding()
            
            Spacer()
        }
        
        .fullScreenCover(isPresented: $showProfile) {
            ProfileView(authViewModel: authViewModel)
        }
        .onAppear {
            if authViewModel.currentUser == nil {
                authViewModel.checkCurrentUser()
            }
        }
    }
    
    private func difficultyButton(titleKey: String, subtitle: String, color: Color, difficulty: Difficulty) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(NSLocalizedString(titleKey, comment: "Difficulty level"))
                    .font(.system(size: 28, weight: .bold))
                Text(subtitle)
                    .font(.system(size: 18))
                    .opacity(1)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 20, weight: .semibold))
        }
        .padding(.horizontal, 25)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.1))
        .foregroundColor(color)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.5), lineWidth: 1)
        )
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
