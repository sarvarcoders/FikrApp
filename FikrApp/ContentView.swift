import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var message: String = ""

    @StateObject var vm = FeedbackViewModel()
    let firestore = FirestoreService()

    var body: some View {
        NavigationView {
            VStack {
                TextField("Yozmoqchi bo‘lgan fikringiz...", text: $message)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button("Jo‘natish") {
                    if let user = authVM.user {
                        firestore.addFeedback(
                            userID: user.uid,
                            email: user.email ?? "unknown",
                            message: message
                        ) { error in
                            if error == nil {
                                message = ""
                                vm.loadFeedbacks() // yangi fikr kiritilganda yangilab qo‘yamiz
                            }
                        }
                    }
                }
                .frame(width: 300, height: 50)
                .background(.blue)
                .foregroundColor(.white)
                .cornerRadius(25)

                List(vm.feedbacks) { item in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .center, spacing: 10) {
                            AsyncImage(url: URL(string: item.profile?.photoURL ?? "")) { image in
                                image.resizable()
                            } placeholder: {
                                Circle().fill(Color.gray.opacity(0.3))
                            }
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())

                            VStack(alignment: .leading) {
                                Text(item.profile?.name ?? "Unknown User")
                                    .font(.subheadline).bold()
                                Text(item.feedback.timestamp.formatted())
                                    .font(.caption).foregroundColor(.gray)
                            }

                            Spacer()

                            if item.feedback.userID == authVM.user?.uid {
                                Button(action: {
                                    firestore.deleteFeedback(item.feedback) { error in
                                        if let error = error {
                                            print("Delete error:", error.localizedDescription)
                                        } else {
                                            vm.loadFeedbacks()
                                        }
                                    }
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }

                        Text(item.feedback.message)
                            .font(.body)

                        HStack {
                            Spacer()
                            let alreadyLiked = item.feedback.likedBy.contains(authVM.user?.uid ?? "")
                            Button(action: {
                                if let uid = authVM.user?.uid, !alreadyLiked {
                                    firestore.likeFeedback(item.feedback, currentUserID: uid)
                                }
                            }) {
                                Label("\(item.feedback.likedBy.count)", systemImage: alreadyLiked ? "heart.fill" : "heart")
                                    .foregroundColor(alreadyLiked ? .red : .gray)
                            }
                            .buttonStyle(.borderless)
                        }

                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    .padding(.vertical, 4)
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
            }
            .navigationTitle("Fikrlar App")
            .toolbar {
                Button("Chiqish") {
                    authVM.signOut()
                }
            }
            .onAppear {
                vm.loadFeedbacks()
            }
        }
    }
}


#Preview {
    ContentView()
}
