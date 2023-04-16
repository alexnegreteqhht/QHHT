import Foundation
import SwiftUI

class UserProfile: ObservableObject, Identifiable {
    @Published var systemId: String = ""
    @Published var systemName: String = ""
    @Published var systemEmail: String = ""
    @Published var systemLocation: String = ""
    @Published var id: String = ""
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var location: String = ""
    @Published var phone: String = ""
    @Published var headline: String = ""
    @Published var link: String = ""
    @Published var profileImageURL: String? = ""
    @Published var credentialImageURL: String? = ""
    @Published var birthday: Date = Date()
    @Published var joined: Date = Date()
    @Published var active: Date = Date()
    @Published var verified: Bool = false
    
    init() {

    }
    
    init(name: String, headline: String, location: String, link: String, profileImageURL: String?) {
        self.name = name
        self.headline = headline
        self.location = location
        self.link = link
        self.profileImageURL = profileImageURL
    }
}

class UserProfileData: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var profileImage: UIImage?
    
    static func previewData() -> UserProfileData {
        let userProfileData = UserProfileData()
        userProfileData.userProfile = UserProfile(name: "John Doe", headline: "SwiftUI enthusiast", location: "Anytown, USA", link: "https://www.apple.com", profileImageURL: "")
        return userProfileData
    }
}
