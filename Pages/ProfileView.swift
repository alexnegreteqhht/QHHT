import SwiftUI
import Firebase
import FirebaseFirestore
import Combine

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AppData())
    }
}

struct ProfileView: View {
    @State private var userProfile = UserProfile()
    @State private var tempProfileImage: UIImage? = nil
    @State private var hasProfileImageLoaded = false
    @State private var showEditProfile = false
    @State private var showSettings = false
    @State private var isContentLoaded = false
    @State var userPhoto: UIImage? = nil
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    ProfileImage(tempProfileImage: $tempProfileImage, userProfile: userProfile, hasProfileImageLoaded: $hasProfileImageLoaded, showEditProfile: $showEditProfile)
                    Text(userProfile.userName)
                        .font(.title)
                        .fontWeight(.bold)
                    Text(userProfile.userBio)
                        .font(.callout)
                        .foregroundColor(.primary)
                    EditProfileButton(showEditProfile: $showEditProfile, userProfile: userProfile, tempProfileImage: $tempProfileImage, onProfileUpdated: {
                        FirebaseHelper.shared.fetchUserData { fetchedUserProfile in
                            self.userProfile = fetchedUserProfile
                            FirebaseHelper.shared.loadImage(urlString: userProfile.userProfileImage) { uiImage in
                                tempProfileImage = uiImage
                            }
                        }
                    })
                    SettingsButton(showSettings: $showSettings, userProfile: userProfile)
                        .padding(.top, 8)
                }
                
                .padding(.top, 50)
                .padding(.horizontal, geometry.size.width * 0.05)
                .navigationBarTitle("Profile", displayMode: .large)
            }
        }
        .onAppear {
            FirebaseHelper.shared.fetchUserData { fetchedUserProfile in
                self.userProfile = fetchedUserProfile
                isContentLoaded = true
                
                FirebaseHelper.shared.loadImage(urlString: userProfile.userProfileImage) { uiImage in
                    tempProfileImage = uiImage
                    hasProfileImageLoaded = true
                }
            }
        }
    }
}

struct ProfileImage: View {
    @Binding var tempProfileImage: UIImage?
    @ObservedObject var userProfile: UserProfile
    @Binding var hasProfileImageLoaded: Bool
    @Binding var showEditProfile: Bool
    
    var body: some View {
        Group {
            if let tempImage = tempProfileImage {
                Image(uiImage: tempImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
            } else {
                if let urlString = userProfile.userProfileImage, !urlString.isEmpty, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        if hasProfileImageLoaded {
                            ProgressView()
                        }
                    }
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .task {
                        hasProfileImageLoaded = true
                    }
                } else {
                    Button(action: {
                        showEditProfile.toggle()
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
    @Binding var showEditProfile: Bool
    @ObservedObject var userProfile: UserProfile
    @Binding var tempProfileImage: UIImage?
    var onProfileUpdated: (() -> Void)?
    
    var body: some View {
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
            EditProfileView(userProfile: userProfile, userPhoto: tempProfileImage, onProfilePhotoUpdated: { newImage in
                tempProfileImage = newImage
            }, onProfileUpdated: onProfileUpdated)
        }
    }
}

struct SettingsButton: View {
    @Binding var showSettings: Bool
    @ObservedObject var userProfile: UserProfile
    
    var body: some View {
        Button(action: {
            showSettings.toggle()
        }) {
            Text("Settings")
        }
        .padding(.horizontal, 20)
        .sheet(isPresented: $showSettings) {
            SettingsView(userProfile: userProfile)
        }
    }
}
