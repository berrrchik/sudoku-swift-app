import SwiftUI

struct ContentView: View {
    @ObservedObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            if authViewModel.currentUser == nil {
                LoginView(authViewModel: authViewModel)
            } else {
                DifficultySelectionView(authViewModel: authViewModel)
            }
        }
    }
}

#Preview {
    ContentView(authViewModel: AuthViewModel())
}

