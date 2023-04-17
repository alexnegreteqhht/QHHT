import Foundation
import SwiftUI

class UserProfile: ObservableObject, Identifiable, Equatable {
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
    
    static func == (lhs: UserProfile, rhs: UserProfile) -> Bool {
            return lhs.name == rhs.name &&
                lhs.headline == rhs.headline &&
                lhs.location == rhs.location &&
                lhs.link == rhs.link &&
                lhs.profileImageURL == rhs.profileImageURL
        }
    
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
    @Published var isLoading: Bool = false
    
    static func previewData() -> UserProfileData {
        let userProfileData = UserProfileData()
        userProfileData.userProfile = UserProfile(name: "Delores Cannon", headline: "QHHT Hypnotherapist", location: "Huntsville, AR", link: "https://www.qhhtofficial.com", profileImageURL: "https://s.lubimyczytac.pl/upload/authors/44592/330283-352x500.jpg")
        return userProfileData
    }
}
