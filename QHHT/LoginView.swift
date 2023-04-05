//
//  LoginView.swift
//  QHHT
//
//  Created by Alex Negrete on 4/4/23.
//

import SwiftUI
import AuthenticationServices
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import CryptoKit

struct LoginPage_Previews: PreviewProvider {
    static var previews: some View {
        LoginPage(isAuthenticated: .constant(false))
    }
}

struct LoginPage: View {
    @Binding var isAuthenticated: Bool

    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 20) {
                Text("QHHT")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Welcome!")
                    .font(.title)
                    .fontWeight(.medium)

                SignInWithAppleButton(isAuthenticated: $isAuthenticated)
                    .frame(width: 280, height: 45)
            }

            Spacer()
        }
        .padding()
    }
}

struct SignInWithAppleButton: UIViewRepresentable {
    @Binding var isAuthenticated: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        button.addTarget(context.coordinator, action: #selector(Coordinator.didTapButton), for: .touchUpInside)
        return button
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {}
    
    class Coordinator: NSObject, ASAuthorizationControllerDelegate {
        let parent: SignInWithAppleButton
        
        init(_ parent: SignInWithAppleButton) {
            self.parent = parent
        }
        
        @objc func didTapButton() {
            let nonce = randomNonceString()
            currentNonce = nonce
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = sha256(nonce)
            
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.performRequests()
        }
        
        private func sha256(_ input: String) -> String {
            let inputData = Data(input.utf8)
            let hashedData = SHA256.hash(data: inputData)
            let hashString = hashedData.compactMap {
                return String(format: "%02x", $0)
            }.joined()
            
            return hashString
        }
        
        private var currentNonce: String?
        
        private func randomNonceString(length: Int = 32) -> String {
            precondition(length > 0)
            let charset: Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz")
            var result = ""
            var remainingLength = length
            
            while remainingLength > 0 {
                let randoms: [UInt8] = (0 ..< 16).map { _ in
                    var random: UInt8 = 0
                    let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                    if errorCode != errSecSuccess {
                        fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                    }
                    return random
                }
                
                randoms.forEach { random in
                    if remainingLength == 0 {
                        return
                    }
                    
                    if random < charset.count {
                        result.append(charset[Int(random)])
                        remainingLength -= 1
                    }
                }
            }
            
            return result
        }
        
        func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            guard let credentials = authorization.credential as? ASAuthorizationAppleIDCredential else {
                    return
                }
            
            // Perform necessary actions after successful login, e.g., navigate to the main app view
            parent.isAuthenticated = true
            
            if let nonce = currentNonce, let identityToken = credentials.identityToken, let identityTokenString = String(data: identityToken, encoding: .utf8) {
                let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                          idToken: identityTokenString,
                                                          rawNonce: nonce)
                
                Auth.auth().signIn(with: credential) { (authResult, error) in
                    if let error = error {
                        print("Error authenticating with Firebase: \(error.localizedDescription)")
                        return
                    }
                    // Handle successful authentication and perform any necessary actions
                                
                    // Retrieve user information
                    print(credentials)
                    
                    // Get the Firebase user
                    guard let currentUser = Auth.auth().currentUser else { return }
                    let fullName = credentials.fullName
                    let email = credentials.email
                    
                    // Add to Firestore
                    let db = Firestore.firestore()
                    let usersCollection = db.collection("users")
                    
                    let userData: [String: Any] = [
                        "uid": currentUser.uid,
                        "fullName": "\(fullName?.givenName ?? "") \(fullName?.familyName ?? "")",
                        "email": email ?? ""
                    ]
                                    
                    print("currentUser.uid: ", currentUser.uid, " fullName: ", fullName ?? "No Name", " email: ", email ?? "No Email")
                    
                    usersCollection.document(currentUser.uid).setData(userData, merge: true) { error in
                        if let error = error {
                            print("Error adding user document: \(error.localizedDescription)")
                        } else {
                            print("User document added with ID: \(currentUser.uid)")
                        }
                    }
                }
            } else {
                print("Error: Failed to retrieve nonce or identity token")
            }
        }
    }
}
