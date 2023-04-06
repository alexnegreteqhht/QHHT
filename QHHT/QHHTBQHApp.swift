import SwiftUI
import AuthenticationServices
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()

        return true
    }
}

class AuthStateDelegate: ObservableObject {
    @Published var isAuthenticated = false
    
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                self.isAuthenticated = true
            } else {
                self.isAuthenticated = false
            }
        }
    }
    
    deinit {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}

@main
struct QHHTBQHApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authStateDelegate = AuthStateDelegate()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                if authStateDelegate.isAuthenticated {
                    ContentView()
                } else {
                    LoginPage()
                }
            }.environmentObject(authStateDelegate)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var authStateDelegate: AuthStateDelegate
    
    var body: some View {
        VStack {
            Text("Welcome to the app!")
                .padding()
            
            Button(action: {
                // Log out the user and set the isAuthenticated variable to false
                try? Auth.auth().signOut()
            }, label: {
                Text("Log Out")
            })
        }
    }
}

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
