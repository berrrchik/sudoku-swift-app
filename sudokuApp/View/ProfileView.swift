import Foundation
import SwiftUI

struct ProfileView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text(NSLocalizedString("back", comment: "Back button"))
                    }
                    .foregroundColor(.blue)
                    .font(.system(size: 20, weight: .medium))
                }

                Spacer()

                Button(action: {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        window.rootViewController = UIHostingController(rootView: LoginView(authViewModel: AuthViewModel()))
                    }
                }) {
                    Text(NSLocalizedString("logout", comment: "Logout button"))
                        .foregroundColor(.red)
                        .font(.system(size: 20, weight: .medium))
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))

            ScrollView {
                VStack(spacing: 0) {
                    VStack(spacing: 8) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)

                        Text(authViewModel.currentUser?.email ?? NSLocalizedString("player", comment: "Default player name"))
                            .font(.system(size: 24, weight: .bold))

                        Text(String(format: NSLocalizedString("total.score", comment: "Total score"), authViewModel.currentUser?.totalPoints ?? 0))
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 30)

                    VStack(spacing: 20) {
                        statisticCard(
                            title: NSLocalizedString("easy.level", comment: "Easy level"),
                            solved: authViewModel.currentUser?.easySudokuSolved ?? 0,
                            points: authViewModel.currentUser?.easyPoints ?? 0,
                            color: .green
                        )

                        statisticCard(
                            title: NSLocalizedString("medium.level", comment: "Medium level"),
                            solved: authViewModel.currentUser?.mediumSudokuSolved ?? 0,
                            points: authViewModel.currentUser?.mediumPoints ?? 0,
                            color: .orange
                        )

                        statisticCard(
                            title: NSLocalizedString("hard.level", comment: "Hard level"),
                            solved: authViewModel.currentUser?.hardSudokuSolved ?? 0,
                            points: authViewModel.currentUser?.hardPoints ?? 0,
                            color: .red
                        )
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if authViewModel.currentUser == nil {
                authViewModel.checkCurrentUser()
            }
        }
    }

    private func statisticCard(title: String, solved: Int, points: Int, color: Color) -> some View {
        VStack(spacing: 15) {
            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(color)

            HStack(spacing: 30) {
                VStack {
                    Text("\(solved)")
                        .font(.system(size: 30, weight: .bold))
                    Text(NSLocalizedString("solved", comment: "Solved label"))
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }

                VStack {
                    Text("\(points)")
                        .font(.system(size: 30, weight: .bold))
                    Text(NSLocalizedString("points", comment: "Points label"))
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.5), lineWidth: 1)
        )
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
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
        return ProfileView(authViewModel: mockAuthViewModel)
    }
}
