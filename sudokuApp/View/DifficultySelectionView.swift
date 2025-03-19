import SwiftUI

struct DifficultySelectionView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var showProfile = false
    @State private var path: [Difficulty] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                HStack {
                    let player = NSLocalizedString("player.text", comment: "Default player name")
                    Text(String(format: NSLocalizedString("greeting", comment: "Greeting message"), authViewModel.currentUser?.email ?? player))
                        .font(.system(size: 18, weight: .medium))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .padding(.leading)
                    
                    Spacer()
                    
                    NavigationLink(destination: ProfileView(authViewModel: authViewModel)) {
                        HStack(spacing: 4) {
                            Text(NSLocalizedString("profile.button", comment: "Profile button"))
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
                        Text(NSLocalizedString("sudoku.text", comment: "Sudoku text"))
                            .font(.system(size: 40, weight: .bold))
                        Text(NSLocalizedString("choose.level", comment: "Choose difficulty level"))
                            .font(.system(size: 22))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 60)
                    
                    VStack(spacing: 20) {
                        NavigationLink(value: Difficulty.easy) {
                            difficultyButton(
                                titleKey: "easy",
                                subtitle: "beginner.level.subtitle",
                                color: .green
                            )
                        }
                        NavigationLink(value: Difficulty.medium) {
                            difficultyButton(
                                titleKey: "medium",
                                subtitle: "intermediate.level.subtitle",
                                color: .orange
                            )
                        }
                        NavigationLink(value: Difficulty.hard) {
                            difficultyButton(
                                titleKey: "hard",
                                subtitle: "advanced.level.subtitle",
                                color: .red
                            )
                        }
                    }
                }
                .padding()
                Spacer()
            }
            .navigationBarBackButtonHidden(true)
            .navigationDestination(for: Difficulty.self) { difficulty in
                SudokuGameView(difficulty: difficulty)
            }
        }
    }
    
    private func difficultyButton(titleKey: String, subtitle: String, color: Color) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(NSLocalizedString(titleKey, comment: "Difficulty level"))
                    .font(.system(size: 28, weight: .bold))
                Text(NSLocalizedString(subtitle, comment: "Difficulty level subtitle"))
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
    return DifficultySelectionView(authViewModel: mockAuthViewModel)
}
