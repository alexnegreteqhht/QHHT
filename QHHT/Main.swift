////
////  Main.swift
////  QHHT-BQH
////
////  Created by Alex Negrete on 4/13/23.
////
//
//import Foundation
//import SwiftUI
//
//@main
//struct QHHTBQHApp: App {
//    // register app delegate for Firebase setup
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
//    @StateObject private var authStateDelegate = AuthStateDelegate()
//
//    var body: some Scene {
//        WindowGroup {
//            NavigationView {
//                if authStateDelegate.isAuthenticated {
//                    ContentView()
//                } else {
//                    LoginPage()
//                }
//            }.environmentObject(authStateDelegate)
//        }
//    }
//}
//
