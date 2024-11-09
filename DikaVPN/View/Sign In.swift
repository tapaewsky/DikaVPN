import SwiftUI
import AuthenticationServices
import FirebaseAuth

struct SignIn: View {
    var onSignInSuccess: () -> Void

    @StateObject private var motionManager = MotionManager()
    @State private var animate = false

    var body: some View {
        VStack {
            GeometryReader { geometry in
                Image("endPlanetBang")
                    .resizable()
                    .scaledToFill()  // Заполняет весь экран, обрезая края если нужно
                    .frame(width: geometry.size.width/*, height: geometry.size.height*/)
                    .ignoresSafeArea()  // Игнорируем безопасные зоны
                    .transition(.opacity)
            }

            VStack {
                Spacer()
                Text(attributedString)
                    .font(.custom("MontserratAlt1-Medium", size: 45))
                    .foregroundColor(.white)
                    .opacity(0.8)
                Spacer().frame(width: 610, height: 550)
                HStack {
                    Spacer()
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.email, .fullName]
                    } onCompletion: { result in
                        switch result {
                        case .success(let authorization):
                            handleSuccess(authorization)
                        case .failure(let error):
                            handleFailure(error)
                        }
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(width: 270, height: 45)
                    .background(Color.clear)
                    .opacity(0.8)
                    Spacer()
                }
                Spacer()
            }
            .padding(.horizontal)
        }
    }

    var attributedString: AttributedString {
        var attributedString = AttributedString("DIKAVPN")
        attributedString.kern = 5
        return attributedString
    }

    private func handleSuccess(_ authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Failed to fetch identity token")
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Failed to decode identity token")
                return
            }
            
            let firebaseCredential = OAuthProvider.credential(
                withProviderID: "apple.com",
                idToken: idTokenString,
                accessToken: nil
            )
            
            Auth.auth().signIn(with: firebaseCredential) { (authResult, error) in
                if let error = error {
                    print("Error signing in with Firebase: \(error.localizedDescription)")
                    return
                }
                
                updateDisplayName(authResult, appleIDCredential: appleIDCredential)
            }
        }
    }

    private func updateDisplayName(_ authResult: AuthDataResult?, appleIDCredential: ASAuthorizationAppleIDCredential) {
        let changeRequest = authResult?.user.createProfileChangeRequest()
        changeRequest?.displayName = appleIDCredential.fullName?.givenName
        changeRequest?.commitChanges { error in
            if let error = error {
                print("Error updating display name: \(error.localizedDescription)")
            } else {
                print("Updated display name: \(Auth.auth().currentUser?.displayName ?? "Unknown")")
                onSignInSuccess()
            }
        }
    }

    private func handleFailure(_ error: Error) {
        print("Failed to sign in with Apple: \(error)")
    }
}

struct SignIn_Previews: PreviewProvider {
    static var previews: some View {
        SignIn {
           
        }
    }
}
