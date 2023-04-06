import SwiftUI

struct DirectoryView_Previews: PreviewProvider {
    static var previews: some View {
        DirectoryView()
        .environmentObject(AppData())
    }
}

// View for the About tab
struct DirectoryView: View {
    // Get the instance of AppData from the environment
    @EnvironmentObject var appData: AppData

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                // Placeholder text
                Text("Practitioner Directory")
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarTitle("Directory")
        }
    }
}
//
//
//import SwiftUI
//
//struct DirectoryView_Previews: PreviewProvider {
//    static var previews: some View {
//        DirectoryView()
//        .environmentObject(AppData())
//    }
//}
//
//// View for the Practitioner tab
//struct DirectoryView: View {
//    // Get the instance of AppData from the environment
//    @EnvironmentObject var appData: AppData
//
//    var body: some View {
//        NavigationStack {
//            ScrollView {
//                VStack(alignment: .leading, spacing: 16) {
//                    // Placeholder text
//                    Text("Your name, credentials, experience, and a personal message go here.")
//                        .font(.body)
//                        .foregroundColor(.primary)
//                        .padding(.horizontal, 20)
//                }
//            }
//            .navigationBarTitle("Practitioner")
//        }
//    }
//}
