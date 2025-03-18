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
        VStack(spacing: 30) {
            VStack(spacing: 10) {
                Text("Добро пожаловать")
                    .font(.system(size: 32, weight: .bold))
                Text("Войдите в свой аккаунт")
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
            }
            .padding(.top, 60)
            
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .foregroundColor(.gray)
                    TextField("Введите email", text: $email)
                        .textFieldStyle(CustomTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Пароль")
                        .foregroundColor(.gray)
                    SecureField("Введите пароль", text: $password)
                        .textFieldStyle(CustomTextFieldStyle())
                }
            }
            
            Button("Войти") {
                authViewModel.login(email: email, password: password) { error in
                    if let error = error {
                        errorMessage = error.localizedDescription
                    } else {
                        onLoginSuccess()
                    }
                }
            }
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(12)

            Text(errorMessage)
                .foregroundColor(.red)
                .font(.caption)

            Spacer()

            Button("Ещё нет аккаунта? Зарегистрируйтесь") {
                showRegistration = true
            }
            .foregroundColor(.blue)
            .padding(.bottom, 30)
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

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
    }
}
