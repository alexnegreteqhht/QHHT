//
//  UserProfileView.swift
//  QHHT-BQH
//
//  Created by Alex Negrete on 4/27/23.
//

import Foundation
import SwiftUI

struct UserProfileView: View {
    let user: UserProfile
    let showApproveButton: Bool

    init(user: UserProfile, showApproveButton: Bool = false) {
        self.user = user
        self.showApproveButton = showApproveButton
    }
    
    var body: some View {
        VStack {
            Text("User profile for \(user.name)")

            if showApproveButton {
                Button(action: {
                    let verificationManager = VerificationManager()
                    verificationManager.approveUser(userProfile: user)
                    // Refresh the list of unapproved practitioners
                    // ...
                }) {
                    Text("Approve")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top)
            }
        }
    }
}
