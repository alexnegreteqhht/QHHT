import Foundation
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

enum FirebaseHelperError: Error {
    case invalidURL
}

struct FirebaseHelper {
    static let shared = FirebaseHelper()
    
    func createUserDocument(systemId: String, systemName: String, systemEmail: String, systemLocation: String, id: String, name: String, email: String, location: String, phone: String, headline: String, link: String, profileImageURL: String, credentialImageURL: String, birthday: Date, joined: Date, active: Date, verified: Bool, specializations: [String], isAdmin: Bool) {
        if let user = Auth.auth().currentUser {
            let db = Firestore.firestore()
            let userDocRef = db.collection("users").document(user.uid)
            userDocRef.setData([
                "systemId": systemId,
                "systemName": systemName,
                "systemEmail": systemEmail,
                "systemLocation": systemLocation,
                "id": id,
                "name": name,
                "email": email,
                "location": location,
                "phone": phone,
                "headline": headline,
                "link": link,
                "profileImageURL": profileImageURL,
                "credentialImageURL": credentialImageURL,
                "birthday": birthday,
                "joined": joined,
                "active": active,
                "verified": verified,
                "specializations": specializations,
                "isAdmin": isAdmin
            ]) { error in
                if let error = error {
                    print("Error creating or updating user document: \(error)")
                } else {
                    print("User document successfully created or updated!")
                }
            }
        }
    }
    
    func fetchUserData(completion: @escaping (UserProfile) -> Void) {
        if let user = Auth.auth().currentUser {
            let db = Firestore.firestore()
            let docRef = db.collection("users").document(user.uid)
            
            docRef.getDocument { (document, error) in
                let userProfile = UserProfile()
                if let document = document, document.exists {
                    userProfile.objectWillChange.send()
                    userProfile.systemId = document.get("systemId") as? String ?? ""
                    userProfile.systemName = document.get("systemName") as? String ?? ""
                    userProfile.systemEmail = document.get("systemEmail") as? String ?? ""
                    userProfile.systemLocation = document.get("systemLocation") as? String ?? ""
                    userProfile.id = document.get("id") as? String ?? ""
                    userProfile.name = document.get("name") as? String ?? ""
                    userProfile.email = document.get("email") as? String ?? ""
                    userProfile.location = document.get("location") as? String ?? ""
                    userProfile.phone = document.get("phone") as? String ?? ""
                    userProfile.headline = document.get("headline") as? String ?? ""
                    userProfile.link = document.get("link") as? String ?? ""
                    userProfile.profileImageURL = document.get("profileImageURL") as? String ?? ""
                    userProfile.credentialImageURL = document.get("credentialImageURL") as? String ?? ""
                    userProfile.birthday = document.get("birthday") as? Date ?? Date()
                    userProfile.joined = document.get("joined") as? Date ?? Date()
                    userProfile.active = document.get("active") as? Date ?? Date()
                    userProfile.verified = document.get("verified") as? Bool ?? false
                    userProfile.specializations = document.get("specializations") as? [String] ?? []
                    userProfile.isAdmin = document.get("isAdmin") as? Bool ?? false
                } else {
                    print("Document does not exist.")
                }
                completion(userProfile)
            }
        }
    }
    
    func checkIfUserExists(systemId: String, completion: @escaping (Bool) -> Void) {
        //was uid
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(systemId)
        docRef.getDocument { (document, error) in
            if let error = error {
                print("Error checking user existence: \(error)")
                completion(false)
                return
            }
            
            if let document = document, document.exists {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    static func uploadImageToStorage(imageData: Data, imagePath: String, completion: @escaping (Result<String, Error>) -> Void) {
        let storage = Storage.storage()
        let storageRef = storage.reference().child(imagePath)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        storageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                completion(.failure(error))
            } else {
                storageRef.downloadURL { url, error in
                    if let error = error {
                        completion(.failure(error))
                    } else if let url = url {
                        completion(.success(url.absoluteString))
                    } else {
                        completion(.failure(FirebaseHelperError.invalidURL))
                    }
                }
            }
        }
    }
    
    static func loadImageFromURL(urlString: String, completion: @escaping (UIImage?, Error?) -> Void) {
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    completion(nil, error)
                } else if let data = data {
                    completion(UIImage(data: data), nil)
                } else {
                    completion(nil, nil)
                }
            }.resume()
        } else {
            completion(nil, NSError(domain: "FirebaseHelper", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
        }
    }
    
    static func downloadImage(url: String, completion: @escaping (Data?) -> Void) {
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
    
    static func fetchUnapprovedPractitioners(completion: @escaping ([UserProfile]) -> Void) {
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
    
    static func fetchUserProfile(userId: String, completion: @escaping (UserProfile?) -> Void) {
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
                
                completion(userProfile)
            } else {
                print("User not found: \(error?.localizedDescription ?? "No error description")")
                completion(nil)
            }
        }
    }
    
    static func loadProfileImage(userProfileData: UserProfileData, completion: @escaping (UIImage?) -> Void) {
        if let userProfile = userProfileData.userProfile, let profileImageURL = userProfile.profileImageURL {
            print("Loading profile image from URL:", profileImageURL)
            userProfileData.isLoading = true
            loadImageFromURL(urlString: profileImageURL) { uiImage, error in
                if let error = error {
                    print("Error loading profile image:", error.localizedDescription)
                } else if let uiImage = uiImage {
                    print("Profile image loaded successfully")
                    DispatchQueue.main.async {
                        completion(uiImage)
                    }
                } else {
                    print("Profile image not loaded, no error returned")
                }
                DispatchQueue.main.async {
                    userProfileData.isLoading = false
                }
            }
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
            FirebaseHelper.downloadImage(url: url) { data in
                imageData = data
            }
        }
    }
}
