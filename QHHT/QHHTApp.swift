import SwiftUI // Import the SwiftUI framework

// Define the main app struct
@main
struct QHHTApp: App {
    @State private var isAuthenticated = false

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
