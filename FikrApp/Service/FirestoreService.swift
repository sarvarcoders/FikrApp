import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirestoreService {
    private let db = Firestore.firestore()
    private let collection = "feedbacks"

    func addFeedback(userID: String, email: String, message: String, completion: @escaping (Error?) -> Void) {
        let feedback = Feedback(userID: userID, userEmail: email, message: message, timestamp: Date(), likedBy: [])
        do {
            _ = try db.collection(collection).addDocument(from: feedback) { error in
                completion(error)
            }
        } catch {
            completion(error)
        }
    }

    func fetchFeedbacks(completion: @escaping ([Feedback]) -> Void) {
        db.collection(collection)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                if let documents = snapshot?.documents {
                    let feedbacks = documents.compactMap { doc -> Feedback? in
                        return try? doc.data(as: Feedback.self)
                    }
                    completion(feedbacks)
                } else {
                    completion([])
                }
            }
    }
    
    func deleteFeedback(_ feedback: Feedback, completion: @escaping (Error?) -> Void) {
        guard let id = feedback.id else {
            completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid feedback ID"]))
            return
        }

        db.collection(collection).document(id).delete(completion: completion)
    }
    
    func likeFeedback(_ feedback: Feedback, currentUserID: String) {
        guard let id = feedback.id else { return }

        let ref = db.collection(collection).document(id)

        db.runTransaction { (transaction, errorPointer) -> Any? in
            let document: DocumentSnapshot
            do {
                document = try transaction.getDocument(ref)
            } catch {
                return nil
            }

            // 🔧 likedBy ni to‘g‘ri aniqlaymiz
            var likedBy = document.data()?["likedBy"] as? [String] ?? []

            // Agar user allaqachon like bosgan bo‘lsa — qaytib chiqamiz
            if likedBy.contains(currentUserID) {
                return nil
            }

            // Aks holda userni ro‘yxatga qo‘shamiz
            likedBy.append(currentUserID)
            transaction.updateData(["likedBy": likedBy], forDocument: ref)
            return nil

        } completion: { (_, error) in
            if let error = error {
                print("Like error:", error.localizedDescription)
            }
        }
    }

    
    func saveUserProfile(userID: String, name: String, photoURL: String, completion: @escaping (Error?) -> Void) {
        let profile = UserProfile(id: userID, name: name, photoURL: photoURL)
        do {
            try db.collection("profiles").document(userID).setData(from: profile) { error in
                completion(error)
            }
        } catch {
            completion(error)
        }
    }


    func fetchUserProfile(userID: String, completion: @escaping (UserProfile?) -> Void) {
        let ref = db.collection("profiles").document(userID)
        ref.getDocument { doc, error in
            if let doc = doc, doc.exists {
                let profile = try? doc.data(as: UserProfile.self)
                completion(profile)
            } else {
                completion(nil)
            }
        }
    }


    
}
