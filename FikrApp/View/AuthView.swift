import SwiftUI

struct AuthView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLogin = true
    @State private var name = ""
    @State private var photoURL = ""

    let firestore = FirestoreService()


    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text(isLogin ? "Kirish" : "Ro'yxatdan o'tish")
                .font(.largeTitle)
                .bold()

            TextField("Email", text: $email)
                .autocapitalization(.none)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Parol", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !isLogin {
                TextField("Nickname yozing", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Profil uchun rasm URL", text: $photoURL)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }


            if let error = authVM.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }

            Button(authVM.isLoading ? "Yuklanmoqda..." : (isLogin ? "Kirish" : "Ro'yxatdan o'tish")) {
                if isLogin {
                    authVM.signIn(email: email, password: password)
                } else {
                    authVM.signUp(email: email, password: password) { user in
                        if let user = user {
                            firestore.saveUserProfile(
                                userID: user.uid,
                                name: name,
                                photoURL: photoURL
                            ) { error in
                                if let error = error {
                                    print("❌ Profile save error:", error.localizedDescription)
                                } else {
                                    print("✅ Profile saved successfully!")
                                }
                            }
                        }
                    }
                }
            }

            .disabled(authVM.isLoading)

            Button(isLogin ? "Sizda hali Profil yo'qmi? Ro'yxatdan o'tish" : "Sizda Profil bormi? Kirish") {
                isLogin.toggle()
            }
            .padding(.top)
            
        }
        .padding()
    }
}
