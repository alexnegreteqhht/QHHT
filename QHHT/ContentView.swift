import SwiftUI // Import the SwiftUI framework

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

// Define the ContentView struct
//struct ContentView: View {
//    
//    // Define the appData @StateObject
//    @StateObject var appData = AppData()
//    
//    // Define the selectedTab @State
//    @State private var selectedTab = 0
//    
//    // Define the ContentView body
//    var body: some View {
//        
//        // Define the TabView
//        TabView(selection: $selectedTab) {
//            
//            // Display the AboutQHHTView as the first tab
//            AboutView()
//                .tabItem {
//                    Image(systemName: "info.circle")
//                    Text("About")
//                }
//                .tag(0)
//                .environmentObject(appData)
//            
//            // Display the AboutPractitionerView as the second tab
//            PractitionerView()
//                .tabItem {
//                    Image(systemName: "person")
//                    Text("Practitioner")
//                }
//                .tag(1)
//                .environmentObject(appData)
//            
//            // Display the ServicesView as the third tab
//            ServicesView()
//                .tabItem {
//                    Image(systemName: "list.bullet")
//                    Text("Services")
//                }
//                .tag(2)
//                .environmentObject(appData)
//            
//            // Display the TestimonialsView as the fourth tab
//            TestimonialsView()
//                .tabItem {
//                    Image(systemName: "star")
//                    Text("Testimonials")
//                }
//                .tag(3)
//                .environmentObject(appData)
//            
//            // Display the ContactView as the fifth tab
//            ContactView()
//                .tabItem {
//                    Image(systemName: "envelope")
//                    Text("Contact")
//                }
//                .tag(4)
//                .environmentObject(appData)
//        }
//        .environmentObject(appData)
//        .navigationBarTitle(getTitleForSelectedTab(), displayMode: .automatic)
//    }
//    
//    // Define a function to get the title for the selected tab
//    func getTitleForSelectedTab() -> String {
//        switch selectedTab {
//        case 0:
//            return "About"
//        case 1:
//            return "Practitioner"
//        case 2:
//            return "Services"
//        case 3:
//            return "Testimonials"
//        case 4:
//            return "Contact"
//        default:
//            return "QHHT"
//        }
//    }
//}
