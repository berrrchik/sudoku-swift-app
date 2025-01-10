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
        VStack(spacing: 20) {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
//            Spacer()
            Button("Register") {
                authViewModel.register(email: email, password: password) { error in
                    if let error = error {
                        errorMessage = error.localizedDescription
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            
            Text(errorMessage)
                .foregroundColor(.red)
            
            Spacer()
            
            Button("Уже есть акккаунт? Войдите") {
                showLogin = true
            }
            .foregroundColor(.blue)
            
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
