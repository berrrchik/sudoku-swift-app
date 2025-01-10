import Foundation
import SwiftUI

struct LoginView: View {
    var onLoginSuccess: () -> Void
    @StateObject private var authViewModel = AuthViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var showRegistration = false
    @State private var showDifficultySelection = false

    var body: some View {
        VStack(spacing: 20) {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("Login") {
                authViewModel.login(email: email, password: password) { error in
                    if let error = error {
                        errorMessage = error.localizedDescription
                    } else {
                        onLoginSuccess()
                    }
                }
            }
            .buttonStyle(.borderedProminent)

            Text(errorMessage)
                .foregroundColor(.red)
                .font(.caption)

            Spacer()

            Button("Ещё нет аккаунта? Зарегистрируйтесь") {
                showRegistration = true
            }
            .foregroundColor(.blue)
        }
        .padding()
        .fullScreenCover(isPresented: $showRegistration) {
            RegistrationView()
        }
        .fullScreenCover(isPresented: $showDifficultySelection) {
            DifficultySelectionView(authViewModel: authViewModel, onDifficultySelected: { _ in })
        }
    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(onLoginSuccess: {})
    }
}
