import SwiftUI
import FirebaseCore


@main
struct sudokuAppApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(authViewModel: AuthViewModel())
                .preferredColorScheme(.light)
        }
    }
}
