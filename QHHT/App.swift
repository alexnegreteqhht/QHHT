import SwiftUI
import AuthenticationServices
import Firebase
import FirebaseAppCheck

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        .environmentObject(AppData())
    }
}

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
       
    // Define the appData @StateObject
    @StateObject var appData = AppData()
       
    // Define the selectedTab @State
    @State private var selectedTab = 0
       
    // Define the ContentView body
    var body: some View {
           
        // Define the TabView
        TabView(selection: $selectedTab) {
               
            // Display the DirectoryView as the second tab
            DirectoryView()
                .navigationBarTitle("Directory", displayMode: .automatic)
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Directory")
                }
                .tag(0)
                .environmentObject(appData)
               
            // Display the ForumView as the third tab
            ForumView()
                .navigationBarTitle("Forum", displayMode: .automatic)
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right")
                    Text("Forum")
                }
                .tag(1)
                .environmentObject(appData)
               
            // Display the ProfileView as the fifth tab
            ProfileView()
                .navigationBarTitle("Me", displayMode: .automatic)
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Me")
                }
                .tag(2)
                .environmentObject(appData)
        }
        .environmentObject(appData)
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
                            return
                        }

                        if let user = authResult?.user {
                            let name = (appleIDCredential.fullName?.givenName ?? "") + " " + (appleIDCredential.fullName?.familyName ?? "")
                            let email = appleIDCredential.email ?? ""
                            let location = ""
                            let userName = name
                            let userEmail = email
                            let userLocation = ""
                            let userPhoneNumber = ""
                            let userBio = ""
                            let userType = ""
                            let userCredentials = ""
                            let userPhotoURL = ""

                            checkIfUserExists(uid: user.uid) { exists in
                                if exists {
                                    print("User document already exists.")
                                } else {
                                    createUserDocument(uid: user.uid, name: name, email: email, location: location, userName: userName, userEmail: userEmail, userLocation: userLocation, userPhoneNumber: userPhoneNumber, userBio: userBio, userType: userType, userCredentials: userCredentials, userPhotoURL: userPhotoURL)
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

func checkIfUserExists(uid: String, completion: @escaping (Bool) -> Void) {
    let db = Firestore.firestore()
    let docRef = db.collection("users").document(uid)

    docRef.getDocument { (document, error) in
        if let error = error {
            print("Error checking user existence: \(error)")
            completion(false)
            return
        }

        if let document = document, document.exists {
            completion(true)
        } else {
            completion(false)
        }
    }
}

func createUserDocument(uid: String, name: String, email: String, location: String, userName: String, userEmail: String, userLocation: String, userPhoneNumber: String, userBio: String, userType: String, userCredentials: String, userPhotoURL: String) {
    if let user = Auth.auth().currentUser {
        let db = Firestore.firestore()
        let userDocRef = db.collection("users").document(user.uid)

        // Create or update the user document with the new fields
        userDocRef.setData([
            "name": name,
            "email": email,
            "location": location,
            "userName": userName,
            "userEmail": userEmail,
            "userLocation": userLocation,
            "userPhoneNumber": userPhoneNumber,
            "userBio": userBio,
            "userType": userType,
            "userCredentials": userCredentials,
            "userPhotoURL": userPhotoURL
        ]) { error in
            if let error = error {
                print("Error creating or updating user document: \(error)")
            } else {
                print("User document successfully created or updated!")
            }
        }
    }
}
