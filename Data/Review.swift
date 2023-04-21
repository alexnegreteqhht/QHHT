//
//  Review.swift
//  QHHT-BQH
//
//  Created by Alex Negrete on 4/21/23.
//

import Foundation

class Review: ObservableObject, Identifiable {
    @Published var id: String
    @Published var reviewerName: String
    @Published var reviewerProfileImageURL: String?
    @Published var rating: Double
    @Published var reviewText: String
    @Published var date: Date
    
    init(id: String, reviewerName: String, reviewerProfileImageURL: String?, rating: Double, reviewText: String, date: Date) {
        self.id = id
        self.reviewerName = reviewerName
        self.reviewerProfileImageURL = reviewerProfileImageURL
        self.rating = rating
        self.reviewText = reviewText
        self.date = date
    }
}

let review1 = Review(id: "1", reviewerName: "John Doe", reviewerProfileImageURL: "https://example.com/johndoe.jpg", rating: 4.5, reviewText: "Great experience! Highly recommended.", date: Date())

let review2 = Review(id: "2", reviewerName: "Jane Smith", reviewerProfileImageURL: "https://example.com/janesmith.jpg", rating: 5.0, reviewText: "Amazing practitioner. Helped me a lot.", date: Date())

let reviews = [review1, review2]

let practitionerProfile = PractitionerProfile(name: "Delores Cannon", headline: "QHHT Hypnotherapist", location: "Huntsville, AR", link: "https://www.qhhtofficial.com", profileImageURL: "https://s.lubimyczytac.pl/upload/authors/44592/330283-352x500.jpg", specializations: ["Hypnotherapy"], rating: 4.75, reviews: reviews)
