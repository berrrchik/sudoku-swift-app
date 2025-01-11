import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

//struct UserModel: Identifiable {
//    let id: String
//    let email: String
//    var totalPoints: Int
//    var easySudokuSolved: Int
//    var mediumSudokuSolved: Int
//    var hardSudokuSolved: Int
//    var easyPoints: Int
//    var mediumPoints: Int
//    var hardPoints: Int
//
//    // Initializer for creating a new user
//    init(id: String, email: String, totalPoints: Int = 0, easySudokuSolved: Int = 0, mediumSudokuSolved: Int = 0, hardSudokuSolved: Int = 0, easyPoints: Int = 0, mediumPoints: Int = 0, hardPoints: Int = 0) {
//        self.id = id
//        self.email = email
//        self.totalPoints = totalPoints
//        self.easySudokuSolved = easySudokuSolved
//        self.mediumSudokuSolved = mediumSudokuSolved
//        self.hardSudokuSolved = hardSudokuSolved
//        self.easyPoints = easyPoints
//        self.mediumPoints = mediumPoints
//        self.hardPoints = hardPoints
//    }
//    
//    // Initializer for creating a UserModel from Firestore data
//    init?(from dictionary: [String: Any]) {
//        guard let id = dictionary["id"] as? String,
//              let email = dictionary["email"] as? String else { return nil }
//
//        self.id = id
//        self.email = email
//        self.totalPoints = dictionary["totalPoints"] as? Int ?? 0
//        self.easySudokuSolved = dictionary["easySudokuSolved"] as? Int ?? 0
//        self.mediumSudokuSolved = dictionary["mediumSudokuSolved"] as? Int ?? 0
//        self.hardSudokuSolved = dictionary["hardSudokuSolved"] as? Int ?? 0
//        self.easyPoints = dictionary["easyPoints"] as? Int ?? 0
//        self.mediumPoints = dictionary["mediumPoints"] as? Int ?? 0
//        self.hardPoints = dictionary["hardPoints"] as? Int ?? 0
//    }
//
//    // Converts the UserModel instance to a Firestore-compatible dictionary
//    var dictionary: [String: Any] {
//        return [
//            "id": id,
//            "email": email,
//            "totalPoints": totalPoints,
//            "easySudokuSolved": easySudokuSolved,
//            "mediumSudokuSolved": mediumSudokuSolved,
//            "hardSudokuSolved": hardSudokuSolved,
//            "easyPoints": easyPoints,
//            "mediumPoints": mediumPoints,
//            "hardPoints": hardPoints
//        ]
//    }
//}

struct UserModel: Identifiable {
    let id: String
    let email: String
    var totalPoints: Int
    var easySudokuSolved: Int
    var mediumSudokuSolved: Int
    var hardSudokuSolved: Int
    var easyPoints: Int
    var mediumPoints: Int
    var hardPoints: Int

    var dictionary: [String: Any] {
        return [
            "id": id,
            "email": email,
            "totalPoints": totalPoints,
            "easySudokuSolved": easySudokuSolved,
            "mediumSudokuSolved": mediumSudokuSolved,
            "hardSudokuSolved": hardSudokuSolved,
            "easyPoints": easyPoints,
            "mediumPoints": mediumPoints,
            "hardPoints": hardPoints
        ]
    }
}

extension UserModel {
    init?(from dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let email = dictionary["email"] as? String else { return nil }

        self.id = id
        self.email = email
        self.totalPoints = dictionary["totalPoints"] as? Int ?? 0
        self.easySudokuSolved = dictionary["easySudokuSolved"] as? Int ?? 0
        self.mediumSudokuSolved = dictionary["mediumSudokuSolved"] as? Int ?? 0
        self.hardSudokuSolved = dictionary["hardSudokuSolved"] as? Int ?? 0
        self.easyPoints = dictionary["easyPoints"] as? Int ?? 0
        self.mediumPoints = dictionary["mediumPoints"] as? Int ?? 0
        self.hardPoints = dictionary["hardPoints"] as? Int ?? 0
    }
}

struct UserModelData {
    var users: [UserModel]
}
