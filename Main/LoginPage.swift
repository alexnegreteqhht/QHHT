import SwiftUI
import AuthenticationServices
import FirebaseAuth

struct LoginPage: View {
    @EnvironmentObject var authStateDelegate: AuthStateDelegate
    
    var body: some View {
        VStack {
            Text("QHHT-BQH")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            Text("Welcome!")
                .font(.title)
                .fontWeight(.medium)
            
            SignInWithAppleButtonView { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                switch result {
                case .success(let authorization):
                    guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
                    let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                              idToken: String(data: appleIDCredential.identityToken!, encoding: .utf8)!,
                                                              rawNonce: nil)

                    Auth.auth().signIn(with: credential) { authResult, error in
                        if let error = error {
                            print("Error signing in with Apple: \(error.localizedDescription)")
                            return
                        }

                        if let user = authResult?.user {
                            checkIfUserExists(uid: user.uid) { exists in
                                if exists {
                                    print("User document already exists.")
                                } else {
                                    let name = (appleIDCredential.fullName?.givenName ?? "") + " " + (appleIDCredential.fullName?.familyName ?? "")
                                    let email = appleIDCredential.email ?? ""
                                    let location = ""
                                    let userName = ""
                                    let userEmail = ""
                                    let userLocation = ""
                                    let userPhoneNumber = ""
                                    let userBio = ""
                                    let userVerification = ""
                                    let userCredential = ""
                                    let userProfileImage = ""
                                    let userBirthday = Date()
                                    let userWebsite = ""
                                    let userJoined = Date()
                                    createUserDocument(uid: user.uid, name: name, email: email, location: location, userName: userName, userEmail: userEmail, userLocation: userLocation, userPhoneNumber: userPhoneNumber, userBio: userBio, userVerification: userVerification, userCredential: userCredential, userProfileImage: userProfileImage, userBirthday: userBirthday, userWebsite: userWebsite, userJoined: userJoined)
                                }
                            }
                        }
                    }

                case .failure(let error):
                    print("Error with Sign in with Apple: \(error.localizedDescription)")
                }
            }

            .frame(width: 280, height: 45)
            .padding()
        }
    }
}

struct SignInWithAppleButtonView: UIViewRepresentable {
    var onRequest: ((ASAuthorizationAppleIDRequest) -> Void)?
    var onCompletion: ((Result<ASAuthorization, Error>) -> Void)?
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(onRequest: onRequest, onCompletion: onCompletion)
    }
    
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let button = ASAuthorizationAppleIDButton()
        button.addTarget(context.coordinator, action: #selector(Coordinator.buttonTapped), for: .touchUpInside)
        return button
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) { }
    
    class Coordinator: NSObject, ASAuthorizationControllerDelegate {
        var onRequest: ((ASAuthorizationAppleIDRequest) -> Void)?
        var onCompletion: ((Result<ASAuthorization, Error>) -> Void)?
        
        init(onRequest: ((ASAuthorizationAppleIDRequest) -> Void)?, onCompletion: ((Result<ASAuthorization, Error>) -> Void)?) {
            self.onRequest = onRequest
            self.onCompletion = onCompletion
        }
        
        @objc func buttonTapped() {
            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()
            onRequest?(request)
            
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.performRequests()
        }
        
        func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            onCompletion?(.success(authorization))
        }
        
        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            onCompletion?(.failure(error))
        }
    }
}
