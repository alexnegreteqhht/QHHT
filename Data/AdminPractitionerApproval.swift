//
//  AdminPractitionerApproval.swift
//  QHHT-BQH
//
//  Created by Alex Negrete on 4/21/23.
//

import Foundation
import SwiftUI
import Combine
import FirebaseFirestore
import Firebase
import FirebaseStorage

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
    @State private var unapprovedPractitioners: [UserProfile] = [] // Change to UserProfile

    func fetchUnapprovedPractitioners(completion: @escaping ([UserProfile]) -> Void) {
        let db = Firestore.firestore()
        let usersCollectionRef = db.collection("users")
        
        // Query users who have submitted a credentialImageURL and are not approved
        usersCollectionRef.whereField("credentialImageURL", isNotEqualTo: "").whereField("verified", isEqualTo: false).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching unapproved practitioners: \(error.localizedDescription)")
                completion([])
            } else {
                print("Number of documents fetched: \(querySnapshot!.documents.count)")
                var unapprovedPractitioners: [UserProfile] = []
                for document in querySnapshot!.documents {
                    print("Fetched document data: \(document.data())")
                    let userProfile = UserProfile()
                    // Parse the document data and populate the userProfile instance
                    // For example:
                    userProfile.id = document.documentID // Add this line
                    userProfile.name = document.get("name") as? String ?? ""
                    userProfile.headline = document.get("headline") as? String ?? ""
                    userProfile.location = document.get("location") as? String ?? ""
                    userProfile.link = document.get("link") as? String ?? ""
                    userProfile.profileImageURL = document.get("profileImageURL") as? String
                    userProfile.credentialImageURL = document.get("credentialImageURL") as? String
                    // ... (Add any other necessary fields)
                    
                    unapprovedPractitioners.append(userProfile)
                    
                    print("Fetched practitioner: \(userProfile)")
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
        NavigationView {
            List(unapprovedPractitioners, id: \.id) { practitioner in // Add 'id: \.id' to List
                NavigationLink(destination: UserProfileView(user: practitioner)) {
                    HStack {
                        FirebaseImage(url: practitioner.profileImageURL ?? "")
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())

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
            }
            .onAppear {
                fetchUnapprovedPractitioners { fetchedPractitioners in
                    unapprovedPractitioners = fetchedPractitioners
                    print("Fetched practitioners count: \(unapprovedPractitioners.count)")
                }
            }
        }
    }
}

struct UserProfileView: View {
    var user: UserProfile
    
    var body: some View {
        Text("User profile for \(user.name)")
    }
}

func downloadImage(url: String, completion: @escaping (Data?) -> Void) {
    let storageRef = Storage.storage().reference(forURL: url)
    storageRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
        if let error = error {
            print("Error downloading image: \(error.localizedDescription)")
            completion(nil)
        } else {
            completion(data)
        }
    }
}

struct FirebaseImage: View {
    @State private var imageData: Data?
    let url: String
    
    var body: some View {
        Group {
            if let data = imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
        .onAppear {
            downloadImage(url: url) { data in
                imageData = data
            }
        }
    }
}

struct PractitionerProfileView: View {
    var practitioner: UserProfile

    var body: some View {
        Text("User profile for \(practitioner.name)")
    }
}

