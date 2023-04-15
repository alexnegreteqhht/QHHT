import Foundation
import SwiftUI

struct ContentView: View {
    @ObservedObject var userProfile: UserProfile
    @EnvironmentObject var authStateDelegate: AuthStateDelegate
    @StateObject private var userProfileData = UserProfileData()
    @StateObject var appData = AppData()
    @State private var selectedTab = 0
       
    var body: some View {
        TabView(selection: $selectedTab) {
            DirectoryView()
                .navigationBarTitle("Directory", displayMode: .automatic)
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Directory")
                }
                .tag(0)
                .environmentObject(appData)
               
            ForumView()
                .navigationBarTitle("Forum", displayMode: .automatic)
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right")
                    Text("Forum")
                }
                .tag(1)
                .environmentObject(appData)
               
            ProfileView(userProfile: userProfile)
                .navigationBarTitle("Me", displayMode: .automatic)
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Me")
                }
                .tag(2)
                .environmentObject(appData)
        }
        .onAppear {
            FirebaseHelper().fetchUserData { fetchedUserProfile in
                userProfileData.userProfile = fetchedUserProfile
            }
        }
        .environmentObject(userProfileData)
    }
}
