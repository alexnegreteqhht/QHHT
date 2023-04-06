import SwiftUI
import Firebase

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
    @State private var showEditProfile = false
    
    var body: some View {
            NavigationView {
                GeometryReader { geometry in
                    ScrollView {
                        VStack(alignment: .center, spacing: 20) {
                            // Profile picture
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                                .foregroundColor(.gray)
                            
                            // User name
                            Text("Alex Negrete")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            // Bio
                            Text("Hi everyone! My name is Alex and I created this app. I'm a fan of Delores Cannon's work. I started practicing QHHT & BQH in 2023. I'm excited to meet you all.")
                                .font(.callout)
                                .foregroundColor(.gray)
                            
                            // Edit profile button
                            Button(action: {
                                showEditProfile.toggle()
                            }) {
                                Text("Edit Profile")
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal, 20)
                            .sheet(isPresented: $showEditProfile) {
                                // Replace with your EditProfileView()
                                Text("Edit Profile View")
                            }
                            
                            // Log out button
                            Button(action: {
                                // Log out the user and set the isAuthenticated variable to false
                                try? Auth.auth().signOut()
                            }, label: {
                                Text("Log Out")
                            })
                            
                            Spacer()
                        }
                        .padding(.top, 50)
                                        .padding(.horizontal, geometry.size.width * 0.05) // Apply 5% padding of screen width
                        .navigationBarTitle("Profile", displayMode: .large)
                    }
                }
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
