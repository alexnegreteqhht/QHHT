import Foundation
import SwiftUI
import Photos
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(userProfile: UserProfile(name: "", headline: "", location: "", link: "", profileImageURL: ""))
            .environmentObject(UserProfileData.previewData())
    }
}

struct EditProfileView: View {
    @ObservedObject var userProfile: UserProfile
    @Environment(\.presentationMode) private var presentationMode
    @Binding var profileImage: UIImage?
    @State private var profileImageData: Data? = nil
    @State private var showImagePicker: Bool = false
    @State private var showAlert: Bool = false
    @State private var errorMessage: String = ""
    @State private var credentialImage: UIImage?
    @State private var credentialImageData: Data?
    @State private var showCredentialImagePicker = false
    @State private var isLoadingCredentialImage: Bool = false
    @State private var showDatePicker = false
    @State private var isBirthdaySet = false
    @State private var isLoadingUserPhoto: Bool = false
    @State private var userName: String = ""
    @State private var userBio: String = ""
    @State private var userLocation: String = ""
    @State private var userWebsite: String = ""
    @State private var isSavingProfile: Bool = false
    var onProfileUpdated: (() -> Void)?
    var onProfileImageUpdated: ((UIImage) -> Bool)?
    @State private var isLoading = false
    @State private var hasChanges = false
    @State private var isSaveDisabled = true
    
    func updateUserProfile(userRef: DocumentReference) {
        userRef.updateData([
            "profileImageURL": userProfile.profileImageURL ?? "",
            "name": userProfile.name,
            "headline": userProfile.headline,
            "location": userProfile.location,
            "link": userProfile.link,
        ]) { error in
            if let error = error {
                errorMessage = "Error updating profile: \(error.localizedDescription)"
                showAlert.toggle()
            } else {
                if let profileImageURL = userProfile.profileImageURL {
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
                            isLoading = false
                        }
                    }
                }
                if let profileImageURL = userProfile.profileImageURL {
                    userProfile.profileImageURL = profileImageURL
                }
                DispatchQueue.main.async {
                    onProfileUpdated?()
                    self.presentationMode.wrappedValue.dismiss()
                    isSavingProfile = false
                }
            }
        }
    }
    
    func saveProfile() {
        isSavingProfile = true
        if let user = Auth.auth().currentUser {
            let userRef = Firestore.firestore().collection("users").document(user.uid)
            let dispatchGroup = DispatchGroup()
            
            if let profileImageData = profileImageData {
                dispatchGroup.enter()
                FirebaseHelper.uploadImageToStorage(imageData: profileImageData, imagePath: "profileImages/\(user.uid).jpg") { result in
                    switch result {
                    case .success(let urlString):
                        userProfile.profileImageURL = urlString
                    case .failure(let error):
                        errorMessage = "Error uploading profile image: \(error.localizedDescription)"
                        showAlert.toggle()
                    }
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.notify(queue: .main) {
                updateUserProfile(userRef: userRef)
            }
        }
    }
    
    private var profileImageSection: some View {
        Section {
            if let profileImage = profileImage {
                Button(action: {
                    showImagePicker.toggle()
                }) {
                    Image(uiImage: profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            } else {
                Button(action: {
                    showImagePicker.toggle()
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 75)
                            .foregroundColor(.clear)
                            .frame(width: 150, height: 150)

                        if !isLoadingUserPhoto {
                            Image(systemName: "person.crop.circle.fill.badge.plus")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }

            Button(action: {
                showImagePicker.toggle()
            }) {
                if profileImage != nil {
                    Text("Edit Photo")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .sheet(isPresented: $showImagePicker) {
                            ImagePicker(selectedImage: $profileImage, imageData: $profileImageData)
                        }
                } else {
                    Text("Add Photo")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .sheet(isPresented: $showImagePicker) {
                            ImagePicker(selectedImage: $profileImage, imageData: $profileImageData)
                        }
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $profileImage, imageData: $profileImageData)
        }
    }
    
    private var nameSection: some View {
        Section(header: Text("Name")) {
            TextField("Your identity on the platform", text: $userProfile.name)
            .onChange(of: userProfile.name) { newValue in
                hasChanges = true
                updateSaveButtonState()
            }
        }
    }
    
    private var headlineSection: some View {
        Section(header: Text("Headline")) {
            let headlineBinding = Binding<String>(
                get: { userProfile.headline },
                set: { newValue in
                    var mutableValue = newValue
                    let validatedValue = Validator.validateStringLength(&mutableValue, maxLength: 60)
                    userProfile.headline = mutableValue
                }
            )
            TextField("Introduce yourself to the community", text: headlineBinding)
                .onChange(of: headlineBinding.wrappedValue) { newValue in
                    var mutableValue = newValue
                    let validatedValue = Validator.validateStringLength(&mutableValue, maxLength: 60)
                    headlineBinding.wrappedValue = mutableValue
                }
                .onChange(of: userProfile.headline) { newValue in
                    hasChanges = true
                    updateSaveButtonState()
                }
        }
    }
    
    private var locationSection: some View {
        Section(header: Text("Location")) {
            TextField("Find practitioners near you", text: $userProfile.location)
            .onChange(of: userProfile.location) { newValue in
                hasChanges = true
                updateSaveButtonState()
            }
        }
    }
    
    private var linkSection: some View {
        Section(header: Text("Link")) {
            TextField("Primary website or social media", text: $userProfile.link)
                .autocapitalization(.none)
            .onChange(of: userProfile.link) { newValue in
                hasChanges = true
                updateSaveButtonState()
            }
        }
    }

    var body: some View {
            NavigationStack {
                Form {
                    profileImageSection
                    nameSection
                    headlineSection
                    locationSection
                    linkSection
                }
                .adaptsToKeyboard()
                .ignoresSafeArea(.keyboard)
                .gesture(DragGesture().onChanged({ _ in
                    UIApplication.shared.endEditing()
                }))
                .navigationBarItems(leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }, trailing:
                Group {
                if isSavingProfile {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                } else {
                    Button("Save") {
                        saveProfile()
                    }
                    .disabled(userProfile.name.isEmpty)
                    .disabled(isSaveDisabled)
                }
            })
            .onAppear {
                isLoadingUserPhoto = true
                if let profileImageURL = userProfile.profileImageURL {
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
                            isLoading = false
                        }
                    }
                } else {
                    isLoadingUserPhoto = false
                }
            }
        }
    }
    
    private func updateSaveButtonState() {
        if userProfile.name.isEmpty || !hasChanges {
            isSaveDisabled = true
        } else {
            isSaveDisabled = false
        }
    }
}
