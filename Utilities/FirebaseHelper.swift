import Foundation
import SwiftUI
import FirebaseStorage
import FirebaseAuth
import Firebase

enum FirebaseHelperError: Error {
    case invalidURL
}

struct FirebaseHelper {
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

    static func loadImageFromURL(urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
    
    static let shared = FirebaseHelper()
    
    let dateFormatter: DateFormatter = {
           let formatter = DateFormatter()
           formatter.dateStyle = .medium
           formatter.timeStyle = .none
           return formatter
        
    }()

    
    func fetchUserData(completion: @escaping (UserProfile) -> Void) {
        if let user = Auth.auth().currentUser {
            let db = Firestore.firestore()
            let docRef = db.collection("users").document(user.uid)

            docRef.getDocument { (document, error) in
                let userProfile = UserProfile(id: "", userName: "", userBio: "", userProfileImage: "")
                if let document = document, document.exists {
                    userProfile.objectWillChange.send()
                    
                    userProfile.name = document.get("name") as? String ?? ""
                    userProfile.email = document.get("email") as? String ?? ""
                    userProfile.location = document.get("location") as? String ?? ""
                    userProfile.userName = document.get("userName") as? String ?? ""
                    userProfile.userEmail = document.get("userEmail") as? String ?? ""
                    userProfile.userLocation = document.get("userLocation") as? String ?? ""
                    userProfile.userPhoneNumber = document.get("userPhoneNumber") as? String ?? ""
                    userProfile.userBio = document.get("userBio") as? String ?? ""
                    userProfile.userVerification = document.get("userVerification") as? String ?? ""
                    userProfile.userCredential = document.get("userCredential") as? String ?? ""
                    userProfile.userProfileImage = document.get("userProfileImage") as? String ?? ""
                    userProfile.userWebsite = document.get("userWebsite") as? String ?? ""

                    if let userBirthdayString = document.get("userBirthday") as? String,
                       let userBirthday = dateFormatter.date(from: userBirthdayString) {
                        userProfile.userBirthday = userBirthday
                    } else {
                        userProfile.userBirthday = Date()
                    }

                    if let userJoinedString = document.get("userJoined") as? String,
                       let userJoined = dateFormatter.date(from: userJoinedString) {
                        userProfile.userJoined = userJoined
                    } else {
                        userProfile.userJoined = Date()
                    }
                } else {
                    print("Document does not exist.")
                }
                completion(userProfile)
            }
        }
    }
        
    func loadImage(urlString: String?, completion: @escaping (UIImage?) -> Void) {
        if let urlString = urlString, let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let uiImage = UIImage(data: data) {
                    DispatchQueue.main.async {
                        completion(uiImage)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }.resume()
        } else {
            completion(nil)
        }
    }
}

func checkIfUserExists(uid: String, completion: @escaping (Bool) -> Void) {
    let db = Firestore.firestore()
    let docRef = db.collection("users").document(uid)
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

func createUserDocument(uid: String, name: String, email: String, location: String, userName: String, userEmail: String, userLocation: String, userPhoneNumber: String, userBio: String, userVerification: String, userCredential: String, userProfileImage: String, userBirthday: Date, userWebsite: String, userJoined: Date) {
    if let user = Auth.auth().currentUser {
        let db = Firestore.firestore()
        let userDocRef = db.collection("users").document(user.uid)
        // Create or update the user document with the new fields
        userDocRef.setData([
            "name": name,
            "email": email,
            "location": location,
            "userName": userName,
            "userEmail": userEmail,
            "userLocation": userLocation,
            "userPhoneNumber": userPhoneNumber,
            "userBio": userBio,
            "userVerification": userVerification,
            "userCredential": userCredential,
            "userProfileImage": userProfileImage,
            "userBirthday": userBirthday,
            "userWebsite": userWebsite,
            "userJoined": userJoined
        ]) { error in
            if let error = error {
                print("Error creating or updating user document: \(error)")
            } else {
                print("User document successfully created or updated!")
            }
        }
    }
}
