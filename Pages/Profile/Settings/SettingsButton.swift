//
//  SettingsButton.swift
//  QHHT-BQH
//
//  Created by Alex Negrete on 4/21/23.
//

import Foundation
import SwiftUI

struct SettingsButton: View {
    @Binding var isSettingsPresented: Bool
    @ObservedObject var userProfile: UserProfile
    
    var body: some View {
        Button(action: {
            isSettingsPresented.toggle()
        }) {
            Text("Settings")
        }
        .padding(.horizontal, 20)
        .sheet(isPresented: $isSettingsPresented) {
            SettingsView(userProfile: userProfile)
        }
    }
}
