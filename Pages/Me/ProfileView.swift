import SwiftUI
import Firebase
import FirebaseFirestore
import Combine

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(userProfile: UserProfile(name: "", headline: "", profileImageURL: ""))
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
    
    private let profileImageSize: CGFloat = 150
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .center, spacing: 16) {
                        if let userProfile = userProfileData.userProfile {
                            ProfileImage(userProfile: userProfile, tempProfileImage: $tempProfileImage, hasProfileImageLoaded: $hasProfileImageLoaded, isEditProfilePresented: $isEditProfilePresented)
                                .frame(width: profileImageSize, height: profileImageSize)
                            
                            Text(userProfile.name)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text(userProfile.headline)
                                .font(.callout)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            EditProfileButton(isEditProfilePresented: $isEditProfilePresented, userProfile: userProfile, tempProfileImage: $tempProfileImage, onProfileUpdated: loadProfileImage)
                            
                            SettingsButton(isSettingsPresented: $isSettingsPresented, userProfile: userProfile)
                        }
                    }
                    .padding(.top, 50)
                    .padding(.horizontal, geometry.size.width * 0.05)
                    .navigationBarTitle("Profile", displayMode: .large)
                }
            }
            .onAppear(perform: loadProfileImage)
        }
    }
    
    private func loadProfileImage() {
        if let profileImageURL = userProfile.profileImageURL {
            FirebaseHelper.loadImageFromURL(urlString: profileImageURL) { uiImage in
                tempProfileImage = uiImage
            }
        }
    }
}

struct ProfileImage: View {
    @EnvironmentObject var userProfileData: UserProfileData
    @ObservedObject var userProfile: UserProfile
    @Binding var tempProfileImage: UIImage?
    @Binding var hasProfileImageLoaded: Bool
    @Binding var isEditProfilePresented: Bool
    
    var body: some View {
        Group {
            if let tempImage = tempProfileImage {
                Image(uiImage: tempImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
            } else {
                if let urlString = userProfile.profileImageURL, !urlString.isEmpty, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                    }
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .onAppear {
                        if let userProfile = userProfileData.userProfile, let userProfileImageURL = userProfile.profileImageURL {
                            
                            FirebaseHelper.loadImageFromURL(urlString: userProfileImageURL) { uiImage in
                                tempProfileImage = uiImage
                            }
                        }
                    }
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
        }
    }
}

struct EditProfileButton: View {
    @Binding var isEditProfilePresented: Bool
    @ObservedObject var userProfile: UserProfile
    @Binding var tempProfileImage: UIImage?
    var onProfileUpdated: (() -> Void)?
    
    var body: some View {
        Button(action: {
            isEditProfilePresented.toggle()
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
            
            EditProfileView(userProfile: userProfile, profileImage: tempProfileImage)
            
//            EditProfileView(userProfile: userProfile, profileImage: tempProfileImage, onProfileUpdated: { newImage in
//                tempProfileImage = newImage
//            }, onProfileImageUpdated: onProfileUpdated)
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
