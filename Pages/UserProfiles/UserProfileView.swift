import Foundation
import SwiftUI

struct UserProfileView_Previews: PreviewProvider {
    @State static var refreshPreview = false

    static var previews: some View {
        NavigationView {
            UserProfileView(
                user: UserProfile(
                    name: "John Doe",
                    headline: "iOS Developer",
                    location: "San Francisco, CA",
                    link: "https://www.example.com",
                    profileImageURL: ""
                ),
                showApproveButton: false,
                refreshParent: $refreshPreview
            )
            .environmentObject(UserProfileData())
        }
    }
}

struct UserProfileView: View {
    let user: UserProfile
    let showApproveButton: Bool
    @State private var profileImage: UIImage? = nil
    @State private var isLoading = false
    @Binding var refreshParent: Bool

    private let profileImageSize: CGFloat = 150

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .center, spacing: 16) {
                    ProfileImage(userProfile: user, profileImage: $profileImage, isEditProfilePresented: .constant(false))
                        .frame(width: profileImageSize, height: profileImageSize)

                    Text(user.name + (user.verified ? " ☑️" : ""))
                        .font(.title)
                        .fontWeight(.bold)

                    if user.headline != "" {
                        HStack {
                            Text("👋 " + user.headline)
                                .font(.callout)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal)
                    }

                    if user.location != "" {
                        Text("📍 " + user.location)
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }

                    if user.link != "" {
                        Button(action: {
                            if let url = URL(string: user.link) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Text("🔗 " + TextHelper.cleanURLString(user.link))
                                .font(.callout)
                                .foregroundColor(.accentColor)
                        }
                    }

                    if showApproveButton {
                        Button(action: {
                            FirebaseHelper.approveUser(userProfile: user) { result in
                                switch result {
                                case .success():
                                    // Trigger a refresh in the parent view
                                    self.refreshParent = true
                                case .failure(let error):
                                    print("Error approving user: \(error.localizedDescription)")
                                }
                            }
                        }) {
                            Text("Approve")
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.top)
                        .padding(.horizontal, 20)
                        
                        Button(action: {
                            FirebaseHelper.declineUser(userProfile: user) { result in
                                switch result {
                                case .success():
                                    // Trigger a refresh in the parent view
                                    self.refreshParent = true
                                case .failure(let error):
                                    print("Error declining user: \(error.localizedDescription)")
                                }
                            }
                        }) {
                            Text("Decline")
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal, 20)
                        
                    }
                }
                .padding(.top, 50)
                .padding(.horizontal, geometry.size.width * 0.05)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .navigationBarTitle("User Profile", displayMode: .large)
        }
        .onAppear(perform: {
            if profileImage == nil {
                FirebaseHelper.loadImageFromURL(urlString: user.profileImageURL ?? "") { uiImage, error in
                    if let uiImage = uiImage {
                        profileImage = uiImage
                    }
                }
            }
        })
    }
}
