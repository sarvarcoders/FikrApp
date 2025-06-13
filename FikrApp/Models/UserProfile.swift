import Foundation
import FirebaseFirestoreSwift

struct UserProfile: Codable {
    var id: String // uid
    var name: String
    var photoURL: String
}

