import SwiftUI
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

// Define the main app struct
@main
struct QHHTBQHApp: App {
    @State private var isAuthenticated = false
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            if isAuthenticated {
                ContentView()
            } else {
                LoginPage(isAuthenticated: $isAuthenticated)
            }
        }
    }
}
