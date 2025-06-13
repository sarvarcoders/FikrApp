

import Foundation

class FeedbackViewModel: ObservableObject {
    private let firestore = FirestoreService()
    @Published var feedbacks: [FeedbackWithProfile] = []

    func loadFeedbacks() {
        firestore.fetchFeedbacks { rawFeedbacks in
            var result: [FeedbackWithProfile] = []
            let group = DispatchGroup()

            for fb in rawFeedbacks {
                group.enter()
                self.firestore.fetchUserProfile(userID: fb.userID) { profile in
                    let item = FeedbackWithProfile(
                        id: fb.id ?? UUID().uuidString,
                        feedback: fb,
                        profile: profile
                    )
                    result.append(item)
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                self.feedbacks = result.sorted(by: { $0.feedback.timestamp > $1.feedback.timestamp })
            }
        }
    }
}
