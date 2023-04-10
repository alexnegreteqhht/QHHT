import SwiftUI

class AppData: ObservableObject {

}

class UserProfile: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var location: String = ""
    @Published var userName: String = ""
    @Published var userEmail: String = ""
    @Published var userPhoneNumber: String = ""
    @Published var userLocation: String = ""
    @Published var userBio: String = ""
    @Published var userVerification: String = ""
    @Published var userCredential: String? = ""
    @Published var userProfileImage: String? = ""
    @Published var userWebsite: String = ""
    @Published var userBirthday: Date = Date()
    @Published var userJoined: Date = Date()
    @Published var profileImageURL: String? = nil
}
