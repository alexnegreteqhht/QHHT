//
//  EditProfileButton.swift
//  QHHT-BQH
//
//  Created by Alex Negrete on 4/21/23.
//

import Foundation
import SwiftUI

struct EditProfileButton: View {
    @Binding var isEditProfilePresented: Bool
        @ObservedObject var userProfile: UserProfile
        @Binding var tempProfileImage: UIImage?
        @Binding var isSettingsPresented: Bool
        @Binding var profileImage: UIImage?
        var onProfileUpdated: (() -> Void)?
    
    var body: some View {
        Button(action: {
            isEditProfilePresented.toggle()
            isSettingsPresented = false
        }) {
            Text("Edit Profile")
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding(.horizontal, 20)
        .sheet(isPresented: $isEditProfilePresented) {
            EditProfileView(
                userProfile: userProfile,
                profileImage: $profileImage,
                localName: userProfile.name,
                localHeadline: userProfile.headline,
                localLocation: userProfile.location,
                localLink: userProfile.link,
                localSystemLocation: userProfile.systemLocation,
                onProfileUpdated: {
                    // Handle profile updated here, if needed
                },
                onProfileImageUpdated: { updatedProfileImage in
                    profileImage = updatedProfileImage
                    return true
                }
            )
        }
    }
}
