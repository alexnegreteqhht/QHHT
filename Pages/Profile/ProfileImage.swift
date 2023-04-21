//
//  ProfileImage.swift
//  QHHT-BQH
//
//  Created by Alex Negrete on 4/21/23.
//

import Foundation
import SwiftUI

struct ProfileImage: View {
    @EnvironmentObject var userProfileData: UserProfileData
    @ObservedObject var userProfile: UserProfile
    @Binding var profileImage: UIImage?
    @Binding var isEditProfilePresented: Bool
    @State private var isLoading: Bool = false
    
    var body: some View {
        Group {
            if let profileImage = profileImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
            } else if isLoading {
                ProgressView()
                    .frame(width: 150, height: 150)
            } else {
                Button(action: {
                    isEditProfilePresented.toggle()
                }) {
                    Image(systemName: "person.crop.circle.fill.badge.plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .foregroundColor(.gray)
                }
            }
        }
        .onReceive(userProfileData.$isLoading) { newIsLoading in
            isLoading = newIsLoading
        }
    }
}
