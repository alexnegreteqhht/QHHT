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
                            FirebaseHelper().checkIfUserExists(systemId: user.uid) { exists in
                                if exists {
                                    print("User document already exists.")
                                } else {
                                    let systemId = appleIDCredential.user
                                    let systemName = (appleIDCredential.fullName?.givenName ?? "") + " " + (appleIDCredential.fullName?.familyName ?? "")
                                    let systemEmail = appleIDCredential.email ?? ""
                                    let systemLocation = ""
                                    let id = Security.generateRandomNonce(length: 48)
                                    let name = ""
                                    let email = ""
                                    let location = ""
                                    let phone = ""
                                    let headline = ""
                                    let link = ""
                                    let profileImageURL = ""
                                    let credentialImageURL = ""
                                    let birthday = Date()
                                    let joined = Date()
                                    let active = Date()
                                    let verified = false
                                    FirebaseHelper().createUserDocument(systemId: user.uid, systemName: systemName, systemEmail: systemEmail, systemLocation: systemLocation, id: id, name: name, email: email, location: location, phone: phone, headline: headline, link: link, profileImageURL: profileImageURL, credentialImageURL: credentialImageURL, birthday: birthday, joined: joined, active: active, verified: verified)
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
