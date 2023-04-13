////
////  ContentView.swift
////  QHHT-BQH
////
////  Created by Alex Negrete on 4/13/23.
////
//
//import Foundation
//import SwiftUI
//
//struct ContentView: View {
//    @EnvironmentObject var authStateDelegate: AuthStateDelegate
//       
//    // Define the appData @StateObject
//    @StateObject var appData = AppData()
//       
//    // Define the selectedTab @State
//    @State private var selectedTab = 0
//       
//    // Define the ContentView body
//    var body: some View {
//           
//        // Define the TabView
//        TabView(selection: $selectedTab) {
//               
//            // Display the DirectoryView as the first tab
//            DirectoryView()
//                .navigationBarTitle("Directory", displayMode: .automatic)
//                .tabItem {
//                    Image(systemName: "magnifyingglass")
//                    Text("Directory")
//                }
//                .tag(0)
//                .environmentObject(appData)
//               
//            // Display the ForumView as the second tab
//            ForumView()
//                .navigationBarTitle("Forum", displayMode: .automatic)
//                .tabItem {
//                    Image(systemName: "bubble.left.and.bubble.right")
//                    Text("Forum")
//                }
//                .tag(1)
//                .environmentObject(appData)
//               
//            // Display the ProfileView as the third tab
//            ProfileView()
//                .navigationBarTitle("Me", displayMode: .automatic)
//                .tabItem {
//                    Image(systemName: "person.crop.circle")
//                    Text("Me")
//                }
//                .tag(2)
//                .environmentObject(appData)
//        }
//        .environmentObject(appData)
//    }
//}
