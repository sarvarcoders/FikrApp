import Foundation

struct FeedbackWithProfile: Identifiable {
    var id: String
    var feedback: Feedback
    var profile: UserProfile?
}
