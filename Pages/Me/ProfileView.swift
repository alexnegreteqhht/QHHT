import SwiftUI
import Firebase
import FirebaseFirestore
import Combine

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(userProfile: UserProfile(name: "", headline: "", location: "Anytown, USA", link: "https://www.apple.com", profileImageURL: ""))
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
    
    private let profileImageSize: CGFloat = 150
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .center, spacing: 16) {
                        if let userProfile = userProfileData.userProfile {
                            ProfileImage(userProfile: userProfile, profileImage: $profileImage, isEditProfilePresented: $isEditProfilePresented)
                                .frame(width: profileImageSize, height: profileImageSize)
                            
                            Text(userProfile.name)
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
                        
                            EditProfileButton(isEditProfilePresented: $isEditProfilePresented, userProfile: userProfile, tempProfileImage: $tempProfileImage, isSettingsPresented: $isSettingsPresented, onProfileUpdated: loadProfileImage)
                            
                            SettingsButton(isSettingsPresented: $isSettingsPresented, userProfile: userProfile)
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

struct ProfileImage: View {
    @EnvironmentObject var userProfileData: UserProfileData
    @ObservedObject var userProfile: UserProfile
    @Binding var profileImage: UIImage?
    @Binding var isEditProfilePresented: Bool
    @State private var isLoading: Bool = false
    
    var body: some View {
        Group {
            if let profileImage = profileImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
            } else if isLoading {
                ProgressView()
                    .frame(width: 150, height: 150)
            } else {
                Button(action: {
                    isEditProfilePresented.toggle()
                }) {
                    Image(systemName: "person.crop.circle.fill.badge.plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .foregroundColor(.gray)
                }
            }
        }
        .onReceive(userProfileData.$isLoading) { newIsLoading in
            isLoading = newIsLoading
        }
    }
}

struct EditProfileButton: View {
    @Binding var isEditProfilePresented: Bool
    @ObservedObject var userProfile: UserProfile
    @Binding var tempProfileImage: UIImage?
    @Binding var isSettingsPresented: Bool
    var onProfileUpdated: (() -> Void)?
    
    var body: some View {
        Button(action: {
            isEditProfilePresented.toggle()
            isSettingsPresented = false
        }) {
            Text("Edit Profile")
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding(.horizontal, 20)
        .sheet(isPresented: $isEditProfilePresented) {
            EditProfileView(userProfile: userProfile, profileImage: $tempProfileImage)
        }
    }
}

struct SettingsButton: View {
    @Binding var isSettingsPresented: Bool
    @ObservedObject var userProfile: UserProfile
    
    var body: some View {
        Button(action: {
            isSettingsPresented.toggle()
        }) {
            Text("Settings")
        }
        .padding(.horizontal, 20)
        .sheet(isPresented: $isSettingsPresented) {
            SettingsView(userProfile: userProfile)
        }
    }
}
