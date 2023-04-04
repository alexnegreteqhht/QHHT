//
//  LoginView.swift
//  QHHT
//
//  Created by Alex Negrete on 4/4/23.
//

import Foundation
import SwiftUI
import AuthenticationServices
import Security

struct LoginPage_Previews: PreviewProvider {
    static var previews: some View {
        LoginPage(isAuthenticated: .constant(false))
    }
}

func saveToKeychain(service: String, account: String, data: String) -> Bool {
    guard let data = data.data(using: .utf8) else { return false }
    
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: service,
        kSecAttrAccount as String: account,
        kSecValueData as String: data
    ]
    
    let status = SecItemAdd(query as CFDictionary, nil)
    
    return status == errSecSuccess
}

struct SignInWithAppleButton: UIViewRepresentable {
    @Environment(\.presentationMode) var presentationMode
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
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.performRequests()
        }
        
        func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            guard let credentials = authorization.credential as? ASAuthorizationAppleIDCredential else {
                return
            }

            // Retrieve user information
            let userId = credentials.user
            let fullName = credentials.fullName
            let email = credentials.email
            
            // Store user information securely using Keychain Services
            if !saveToKeychain(service: "QHHTApp", account: "userId", data: userId) {
                print("Failed to save userId")
            }
            
            if let fullName = fullName {
                if !saveToKeychain(service: "QHHTApp", account: "fullName", data: "\(fullName.givenName ?? "") \(fullName.familyName ?? "")") {
                    print("Failed to save fullName")
                }
            }
            
            if let email = email {
                if !saveToKeychain(service: "QHHTApp", account: "email", data: email) {
                    print("Failed to save email")
                }
            }
            
            // Perform necessary actions after successful login, e.g., navigate to the main app view
            parent.isAuthenticated = true
        }
        
        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            // Handle error, show an alert or perform other necessary actions
        }
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
