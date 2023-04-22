import Foundation
import SwiftUI

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(userProfile: UserProfile(name: "", headline: "", location: "", link: "", profileImageURL: ""))
            .environmentObject(UserProfileData.previewData())
    }
}

struct ProfileView: View {
    @ObservedObject var userProfile: UserProfile
    @EnvironmentObject var userProfileData: UserProfileData
    @State private var userProfileImage: UIImage? = nil
    @State private var tempProfileImage: UIImage? = nil
    @State private var hasProfileImageLoaded = false
    @State private var isEditProfilePresented = false
    @State private var isSettingsPresented = false
    @State private var isLoading = false
    @State private var profileImage: UIImage? = nil
    @State private var isAdmin = false
    @State private var showAdminView = false
    
    private let profileImageSize: CGFloat = 150
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .center, spacing: 16) {
                        if let userProfile = userProfileData.userProfile {
                            ProfileImage(userProfile: userProfile, profileImage: $profileImage, isEditProfilePresented: $isEditProfilePresented)
                                .frame(width: profileImageSize, height: profileImageSize)
                            
                            Text(userProfile.name + (userProfile.verified ? " ☑️" : ""))
                                .font(.title)
                                .fontWeight(.bold)
                            
                            if userProfile.headline != "" {
                                HStack {
                                    Text("👋 " + userProfile.headline)
                                    .font(.callout)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    
                                }
                                .padding(.horizontal)
                            }
                            
                            if userProfile.location != "" {
                                Text("📍 " + userProfile.location)
                                    .font(.callout)
                                    .foregroundColor(.secondary)
                            }

                            if userProfile.link != "" {
                                Button(action: {
                                    if let url = URL(string: userProfile.link) {
                                        UIApplication.shared.open(url)
                                    }
                                }) {
                                    Text("🔗 " + TextHelper.cleanURLString(userProfile.link))
                                        .font(.callout)
                                        .foregroundColor(.accentColor)
                                }
                            }
                        
                            EditProfileButton(isEditProfilePresented: $isEditProfilePresented, userProfile: userProfile, tempProfileImage: $tempProfileImage, isSettingsPresented: $isSettingsPresented, profileImage: $profileImage, onProfileUpdated: loadProfileImage)
                            
                            SettingsButton(isSettingsPresented: $isSettingsPresented, userProfile: userProfile)
                            
                            if userProfileData.userProfile?.isAdmin == true {
                                Button(action: {
                                    showAdminView.toggle()
                                }, label: {
                                    Text("Admin")
                                })
                                .sheet(isPresented: $showAdminView) {
                                    AdminView()
                                }
                            }
                        }
                    }
                    .padding(.top, 50)
                    .padding(.horizontal, geometry.size.width * 0.05)
                    .navigationBarTitle("Profile", displayMode: .large)
                }
            }
            .onAppear(perform: {
                if profileImage == nil {
                    loadProfileImage()
                }
            })
        }
        .navigationBarTitle("Profile", displayMode: .large)
    }
    
    private func loadProfileImage() {
        if let userProfile = userProfileData.userProfile, let profileImageURL = userProfile.profileImageURL {
            print("Loading profile image from URL:", profileImageURL)
            userProfileData.isLoading = true
            FirebaseHelper.loadImageFromURL(urlString: profileImageURL) { uiImage, error in
                if let error = error {
                    print("Error loading profile image:", error.localizedDescription)
                } else if let uiImage = uiImage {
                    print("Profile image loaded successfully")
                    DispatchQueue.main.async {
                        profileImage = uiImage
                    }
                } else {
                    print("Profile image not loaded, no error returned")
                }
                DispatchQueue.main.async {
                    userProfileData.isLoading = false
                }
            }
        }
    }
}
