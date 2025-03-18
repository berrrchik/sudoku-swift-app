import Foundation
import SwiftUI

struct LoginView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var showRegistration = false
    @State private var showDifficultySelection = false

    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 10) {
                Text(NSLocalizedString("welcome", comment: "Welcome message"))
                    .font(.system(size: 32, weight: .bold))
                Text(NSLocalizedString("login.account", comment: "Login to your account"))
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
            }
            .padding(.top, 60)

            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(NSLocalizedString("email", comment: "Email label"))
                        .foregroundColor(.gray)
                    TextField(NSLocalizedString("enter.email", comment: "Enter email placeholder"), text: $email)
                        .textFieldStyle(CustomTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(NSLocalizedString("password", comment: "Password label"))
                        .foregroundColor(.gray)
                    SecureField(NSLocalizedString("enter.password", comment: "Enter password placeholder"), text: $password)
                        .textFieldStyle(CustomTextFieldStyle())
                }
            }

            Button(NSLocalizedString("login", comment: "Login button")) {
                authViewModel.login(email: email, password: password) { error in
                    if let error = error {
                        errorMessage = error.localizedDescription
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
            
            NavigationLink(NSLocalizedString("no.account.register", comment: "No account? Register"), destination: RegistrationView(authViewModel: authViewModel))
                .navigationBarBackButtonHidden(true)
                .foregroundColor(.blue)
                .padding(.bottom, 30)
        }
        .padding()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(authViewModel: AuthViewModel())
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
