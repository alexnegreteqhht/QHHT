import SwiftUI

class AppData: ObservableObject {

}

class UserProfile: ObservableObject {
    //System
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var location: String = ""
    
    //User
    @Published var userName: String = ""
    @Published var userEmail: String = ""
    @Published var userPhoneNumber: String = ""
    @Published var userLocation: String = ""
    @Published var userBio: String = ""
    @Published var userType: String = ""
    @Published var userCredentials: String = ""
    @Published var userPhotoURL: String = ""
}
