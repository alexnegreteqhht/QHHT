import SwiftUI

class AppData: ObservableObject {
    @Published var resources: [Resource] = [
        Resource(title: "Article", url: "https://www.example.com/article1"),
        Resource(title: "Video", url: "https://www.example.com/video1"),
        Resource(title: "Podcast", url: "https://www.example.com/podcast1")
    ]

    @Published var testimonials: [Testimonial] = [
        Testimonial(name: "Client 1", text: "Client 1's testimonial goes here and here and here."),
        Testimonial(name: "Client 2", text: "Client 2's testimonial goes here and here and here.")
    ]

    @Published var services: [Service] = [
        Service(title: "In-person sessions", price: 100.0, description: "This is a description of in-person sessions."),
        Service(title: "Online sessions", price: 75.0, description: "This is a description of online sessions."),
        Service(title: "Group workshops", price: 50.0, description: "This is a description of group workshops."),
        Service(title: "Classes", price: 25.0, description: "This is a description of classes.")
    ]
    
    let contactInfo = ContactInfo(phone: "(512) 827-8024",
                                      email: "example@email.com",
                                      address: "123 Main St, City, State, Country",
                                      website: "www.example.com",
                                      facebook: "www.facebook.com/example",
                                      instagram: "www.instagram.com/example")
}
