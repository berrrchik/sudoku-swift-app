import Foundation

import SwiftUI

struct RegistrationView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var showLogin = false
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        VStack(spacing: 30) {
            
            VStack(spacing: 10) {
                Text("Создание аккаунта")
                    .font(.system(size: 32, weight: .bold))
                Text("Заполните данные для регистрации")
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
                        .autocapitalization(.none)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Пароль")
                        .foregroundColor(.gray)
                    SecureField("Введите пароль", text: $password)
                        .textFieldStyle(CustomTextFieldStyle())
                }
            }
            
            Button("Зарегистрироваться") {
                authViewModel.register(email: email, password: password) { error in
                    if let error = error {
                        errorMessage = error.localizedDescription
                    } else {
                        presentationMode.wrappedValue.dismiss()
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
            
            Spacer()
            
            Button("Уже есть акккаунт? Войдите") {
                showLogin = true
            }
            .foregroundColor(.blue)
            .padding(.bottom, 30)
            
        }
        .padding()
        .fullScreenCover(isPresented: $showLogin) {
            LoginView(onLoginSuccess: {})
        }
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
}
