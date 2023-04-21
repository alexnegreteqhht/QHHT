//
//  PractitionerProfile.swift
//  QHHT-BQH
//
//  Created by Alex Negrete on 4/21/23.
//

import Foundation

class PractitionerProfile: ObservableObject, Identifiable, Equatable {
    @Published var id: String = ""
    @Published var name: String = ""
    @Published var location: String = ""
    @Published var phone: String = ""
    @Published var email: String = ""
    @Published var headline: String = ""
    @Published var link: String = ""
    @Published var profileImageURL: String? = ""
    @Published var credentialImageURL: String? = ""
    @Published var specializations: [String] = []
    @Published var rating: Double = 0
    @Published var reviews: [Review] = [] // Assuming you have a Review class to store review data
    
    static func == (lhs: PractitionerProfile, rhs: PractitionerProfile) -> Bool {
            return lhs.name == rhs.name &&
                lhs.headline == rhs.headline &&
                lhs.location == rhs.location &&
                lhs.link == rhs.link &&
                lhs.profileImageURL == rhs.profileImageURL
        }
    
    init() {

    }
    
    init(name: String, headline: String, location: String, link: String, profileImageURL: String?, specializations: [String], rating: Double, reviews: [Review]) {
        self.name = name
        self.headline = headline
        self.location = location
        self.link = link
        self.profileImageURL = profileImageURL
        self.specializations = specializations
        self.rating = rating
        self.reviews = reviews
    }
}
