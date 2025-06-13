import Foundation
import FirebaseFirestoreSwift

struct Feedback: Identifiable, Codable {
    @DocumentID var id: String?
    var userID: String
    var userEmail: String
    var message: String
    var timestamp: Date
    var likedBy: [String] // foydalanuvchi UID lar ro‘yxati
}

