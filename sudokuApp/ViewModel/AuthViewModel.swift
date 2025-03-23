import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var currentUser: UserModel?
    private let db = Firestore.firestore()
    
    func register(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                print("Error during registration: \(error.localizedDescription)")
                completion(error)
                return
            }
            
            guard let user = result?.user else {
                completion(NSError(domain: "AuthViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve user after registration"]))
                return
            }
            
            let newUser = UserModel(
                id: user.uid,
                email: email,
                totalPoints: 0,
                easySudokuSolved: 0,
                mediumSudokuSolved: 0,
                hardSudokuSolved: 0,
                easyPoints: 0,
                mediumPoints: 0,
                hardPoints: 0
            )
            
            self?.db.collection("users").document(user.uid).setData(newUser.dictionary) { error in
                if let error = error {
                    print("Error creating user in Firestore: \(error.localizedDescription)")
                    completion(error)
                } else {
                    self?.currentUser = newUser
                    print("User successfully registered and added to Firestore: \(newUser)")
                    completion(nil)
                }
            }
        }
    }
    
    func login(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                print("Error during login: \(error.localizedDescription)")
                completion(error)
                return
            }
            
            guard let user = result?.user else {
                completion(NSError(domain: "AuthViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve user after login"]))
                return
            }
            
            self?.db.collection("users").document(user.uid).getDocument { document, error in
                print("Attempting to fetch document for user ID: \(user.uid)")
                if let error = error {
                    print("Error fetching user data: \(error.localizedDescription)")
                    completion(error)
                    return
                }
                if let document = document, let data = document.data() {
                    var updatedData = data
                    updatedData["id"] = user.uid
                    if let userModel = UserModel(from: updatedData) {
                        self?.currentUser = userModel
                    } else {
                        print("Failed to parse UserModel")
                    }
                } else {
                    print("Document does not exist or data is invalid")
                    completion(NSError(domain: "AuthViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "User data not found"]))
                }
                completion(nil)
            }
        }
    }
    
    func checkCurrentUser() {
        if let user = Auth.auth().currentUser {
            db.collection("users").document(user.uid).getDocument { [weak self] document, error in
                if let error = error {
                    self?.currentUser = nil
                    return
                }
                if let document = document, document.exists {
                    if let data = document.data(), let userModel = UserModel(from: data) {
                        self?.currentUser = userModel
                    } else {
                        self?.currentUser = nil
                    }
                } else {
                    self?.currentUser = nil
                }
            }
        } else {
            currentUser = nil
        }
    }
    
    
    func logout() {
        try? Auth.auth().signOut()
        self.currentUser = nil
    }
    
    func updatePoints(for difficulty: Difficulty, isSolved: Bool) {
        guard let user = currentUser else { return }
        
        var updatedUser = user
        
        if isSolved {
            switch difficulty {
            case .easy:
                updatedUser.easySudokuSolved += 1
                updatedUser.easyPoints += 10
                updatedUser.totalPoints += 10
            case .medium:
                updatedUser.mediumSudokuSolved += 1
                updatedUser.mediumPoints += 20
                updatedUser.totalPoints += 20
            case .hard:
                updatedUser.hardSudokuSolved += 1
                updatedUser.hardPoints += 30
                updatedUser.totalPoints += 30
            }
        }
        
        self.currentUser = updatedUser
        
        db.collection("users").document(user.id).setData(updatedUser.dictionary, merge: true) { error in
            if let error = error {
                print("\(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                    self.checkCurrentUser()
                }
            }
        }
    }
    
}
