import SwiftUI

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
        .environmentObject(AppData())
    }
}

// View for the About tab
struct ProfileView: View {
    // Get the instance of AppData from the environment
    @EnvironmentObject var appData: AppData
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                // Placeholder text
                Text("My Profile")
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarTitle("Profile")
        }
    }
}


//import SwiftUI
//
//struct ContactView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContactView()
//        .environmentObject(AppData())
//    }
//}
//
//// View for the Contact tab
//struct ContactView: View {
//    // Get the instance of AppData from the environment
//    @EnvironmentObject var appData: AppData
//
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                VStack(alignment: .leading, spacing: 16) {
//                    // Placeholder text
//                    Text("Phone: \(appData.contactInfo.phone)")
//                        .font(.body)
//                        .foregroundColor(Color.primary)
//                        .padding(.horizontal, 20)
//                    Text("Email: \(appData.contactInfo.email)")
//                        .font(.body)
//                        .foregroundColor(Color.primary)
//                        .padding(.horizontal, 20)
//                    Text("Address: \(appData.contactInfo.address)")
//                        .font(.body)
//                        .foregroundColor(Color.primary)
//                        .padding(.horizontal, 20)
//                    Text("Website: \(appData.contactInfo.website)")
//                        .font(.body)
//                        .foregroundColor(Color.black)
//                        .padding(.horizontal, 20)
//                    Text("Facebook: \(appData.contactInfo.facebook)")
//                        .font(.body)
//                        .foregroundColor(Color.black)
//                        .padding(.horizontal, 20)
//                    Text("Instagram: \(appData.contactInfo.instagram)")
//                        .font(.body)
//                        .foregroundColor(Color.black)
//                        .padding(.horizontal, 20)
//                }
//            }
//            .navigationBarTitle("Contact")
//        }
//    }
//}
//
//
//////
//////  ContactView.swift
//////  QHHT
//////
//////  Created by Alex Negrete on 3/24/23.
//////
////
////import SwiftUI
////
////struct ContactView_Previews: PreviewProvider {
//////    static var previews: some View {
//////        ContactView()
//////            .environmentObject(AppData())
//////    }
//////}
//////
//////struct ContactView: View {
//////    @EnvironmentObject var appData: AppData
//////
////    var body: some View {
////        VStack {
////            Spacer(minLength: 20)
////            ScrollView {
////                VStack(alignment: .leading, spacing: 16) {
////                    VStack(alignment: .leading, spacing: 8) {
////                        Text("Phone: \(appData.contactInfo.phone)")
////                            .font(.body)
////                            .foregroundColor(Color.primary)
////                            .padding(.horizontal, 20)
////                        Text("Email: \(appData.contactInfo.email)")
////                            .font(.body)
////                            .foregroundColor(Color.primary)
////                            .padding(.horizontal, 20)
////                        Text("Address: \(appData.contactInfo.address)")
////                            .font(.body)
////                            .foregroundColor(Color.primary)
////                            .padding(.horizontal, 20)
////                    }
////                    .padding(.bottom, 20)
////
////                    VStack(alignment: .leading, spacing: 8) {
////                        Text("Website: \(appData.contactInfo.website)")
////                            .font(.body)
////                            .foregroundColor(Color.black)
////                            .padding(.horizontal, 20)
////                        Text("Facebook: \(appData.contactInfo.facebook)")
////                            .font(.body)
////                            .foregroundColor(Color.black)
////                            .padding(.horizontal, 20)
////                        Text("Instagram: \(appData.contactInfo.instagram)")
////                            .font(.body)
////                            .foregroundColor(Color.black)
////                            .padding(.horizontal, 20)
////                    }
////                }
////                .padding(.top, 30)
//////                .edgesIgnoringSafeArea(.bottom)
//////            }
//////        }
//////    }
//////}
