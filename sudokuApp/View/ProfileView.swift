import Foundation
import SwiftUI

struct ProfileView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "arrow.left")
                        Text("Назад")
                    }
                }
                .foregroundColor(.blue)
                .padding()
                
                Spacer()
            }

            Text("Профиль")
                .font(.largeTitle)
                .padding()
            
            Text("Email: \(authViewModel.currentUser?.email ?? "—")")
            Text("Всего очков: \(authViewModel.currentUser?.totalPoints ?? 0)")
            Text("Решено судоку (лёгкий): \(authViewModel.currentUser?.easySudokuSolved ?? 0)")
            Text("Очки за лёгкий уровень: \(authViewModel.currentUser?.easyPoints ?? 0)")
            Text("Решено судоку (средний): \(authViewModel.currentUser?.mediumSudokuSolved ?? 0)")
            Text("Очки за средний уровень: \(authViewModel.currentUser?.mediumSudokuSolved ?? 0)")
            Text("Решено судоку (тяжёлый): \(authViewModel.currentUser?.hardSudokuSolved ?? 0)")
            Text("Очки за тяжёлый уровень: \(authViewModel.currentUser?.hardPoints ?? 0)")
            
            Spacer()
            
            NavigationLink(destination: LoginView(authViewModel: AuthViewModel())) {
                Text("Выйти")
                    .foregroundColor(.red)
                    .padding()
            }
            .simultaneousGesture(TapGesture().onEnded {
                authViewModel.logout()
            })
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if authViewModel.currentUser == nil {
                authViewModel.checkCurrentUser()
            }
        }
    }
}

//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileView(authViewModel: AuthViewModel())
//    }
//}

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
