import SwiftUI

struct Resource: Identifiable {
    let id = UUID()
    let title: String
    let url: String
}

struct Testimonial: Identifiable {
    let id = UUID()
    let name: String
    let text: String
}

struct Service: Identifiable {
    let id = UUID()
    let title: String
    let price: Double
    let description: String
}

struct ContactInfo {
    let phone: String
    let email: String
    let address: String
    let website: String
    let facebook: String
    let instagram: String
}
