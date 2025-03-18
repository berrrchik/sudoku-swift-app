import Foundation
import SwiftUI

struct RegistrationView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var showLogin = false
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 10) {
                Text(NSLocalizedString("create.account", comment: "Create account title"))
                    .font(.system(size: 32, weight: .bold))
                Text(NSLocalizedString("fill.registration.details", comment: "Fill registration details"))
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
                        .autocapitalization(.none)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(NSLocalizedString("password", comment: "Password label"))
                        .foregroundColor(.gray)
                    SecureField(NSLocalizedString("enter.password", comment: "Enter password placeholder"), text: $password)
                        .textFieldStyle(CustomTextFieldStyle())
                }
            }

            Button(NSLocalizedString("register", comment: "Register button")) {
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
            
            NavigationLink(NSLocalizedString("already.have.account", comment: "Already have an account? Login"), destination: LoginView(authViewModel: authViewModel))
                .navigationBarBackButtonHidden(true)
                .foregroundColor(.blue)
                .padding(.bottom, 30)
        }
        .padding()
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView(authViewModel: AuthViewModel())
    }
}
