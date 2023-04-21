//
//  AdminPractitionerApproval.swift
//  QHHT-BQH
//
//  Created by Alex Negrete on 4/21/23.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import Firebase

class VerificationManager {
    func approveUser(userProfile: UserProfile) {
        // Call the helper function to create a PractitionerProfile instance
        let practitionerProfile = userProfileToPractitionerProfile(userProfile: userProfile)

        // Save the practitionerProfile to your backend, e.g., Firebase
        // Update the userProfile's status in the backend to reflect that it's approved
    }
}

func userProfileToPractitionerProfile(userProfile: UserProfile) -> PractitionerProfile {
    let practitionerProfile = PractitionerProfile(
        name: userProfile.name,
        headline: userProfile.headline,
        location: userProfile.location,
        link: userProfile.link,
        profileImageURL: userProfile.profileImageURL,
        specializations: userProfile.specializations,
        rating: 0, // Set the initial rating to 0 or any default value
        reviews: [] // Initialize with an empty list of reviews
    )
    return practitionerProfile
}

func fetchUserProfile(userId: String, completion: @escaping (UserProfile?) -> Void) {
    let db = Firestore.firestore()
    let userDocumentRef = db.collection("users").document(userId)
    
    userDocumentRef.getDocument { (document, error) in
        if let document = document, document.exists {
            let userProfile = UserProfile() // Create a new UserProfile instance
            // Parse the document data and populate the userProfile instance
            // For example:
            userProfile.name = document.get("name") as? String ?? ""
            userProfile.headline = document.get("headline") as? String ?? ""
            userProfile.location = document.get("location") as? String ?? ""
            userProfile.link = document.get("link") as? String ?? ""
            userProfile.profileImageURL = document.get("profileImageURL") as? String
            // ... (Add any other necessary fields)
            
            completion(userProfile)
        } else {
            print("User not found: \(error?.localizedDescription ?? "No error description")")
            completion(nil)
        }
    }
}

struct AdminPractitionerApprovalView: View {
    @State private var unapprovedPractitioners: [UserProfile] = [] // Store unapproved practitioners here

    func fetchUnapprovedPractitioners(completion: @escaping ([UserProfile]) -> Void) {
        let db = Firestore.firestore()
        let usersCollectionRef = db.collection("users")
        
        // Query users who have submitted a credentialImageURL and are not approved
        usersCollectionRef.whereField("credentialImageURL", isNotEqualTo: "").whereField("verified", isEqualTo: false).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching unapproved practitioners: \(error.localizedDescription)")
                completion([])
            } else {
                var unapprovedPractitioners: [UserProfile] = []
                for document in querySnapshot!.documents {
                    let userProfile = UserProfile()
                    // Parse the document data and populate the userProfile instance
                    // For example:
                    userProfile.name = document.get("name") as? String ?? ""
                    userProfile.headline = document.get("headline") as? String ?? ""
                    userProfile.location = document.get("location") as? String ?? ""
                    userProfile.link = document.get("link") as? String ?? ""
                    userProfile.profileImageURL = document.get("profileImageURL") as? String
                    userProfile.credentialImageURL = document.get("credentialImageURL") as? String
                    // ... (Add any other necessary fields)
                    
                    unapprovedPractitioners.append(userProfile)
                }
                completion(unapprovedPractitioners)
            }
        }
    }

    private func approveButton(for practitioner: UserProfile) -> some View {
        Button(action: {
            let verificationManager = VerificationManager()
            verificationManager.approveUser(userProfile: practitioner)
            // Refresh the list of unapproved practitioners
            // ...
        }) {
            Text("Approve")
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }

    var body: some View {
        List(unapprovedPractitioners) { practitioner in
            HStack {
                VStack(alignment: .leading) {
                    Text(practitioner.name)
                        .font(.headline)
                    Text(practitioner.headline)
                        .font(.subheadline)
                }
                Spacer()
                approveButton(for: practitioner)
            }
        }
        .onAppear {
            fetchUnapprovedPractitioners { fetchedPractitioners in
                unapprovedPractitioners = fetchedPractitioners
            }
        }
    }
}
