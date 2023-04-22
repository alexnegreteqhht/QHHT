import Foundation
import SwiftUI
import Photos
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import CoreLocation
import CoreLocationUI

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView(
            userProfile: UserProfile(name: "", headline: "", location: "", link: "", profileImageURL: ""),
            profileImage: .constant(nil),
            localName: "",
            localHeadline: "",
            localLocation: "",
            localLink: "",
            localSystemLocation: ""
        )
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
    @State private var showDatePicker = false
    @State private var isBirthdaySet = false
    @State private var isLoadingProfileImage: Bool = false
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
    @State private var localName: String
    @State private var localHeadline: String
    @State private var localLocation: String
    @State private var localSystemLocation: String
    @State private var localLink: String
    @State private var localProfileImage: UIImage?
    @State private var localProfileImageURL: String?
    @State private var isProfileImageLoaded = false
    @State private var isInitialLoad = true
    @StateObject private var viewModel = EditProfileViewModel()
    
    init(userProfile: UserProfile,
         profileImage: Binding<UIImage?>,
         localName: String,
         localHeadline: String,
         localLocation: String,
         localLink: String,
         localSystemLocation: String,
         onProfileUpdated: (() -> Void)? = nil,
         onProfileImageUpdated: ((UIImage) -> Bool)? = nil) {
        self._userProfile = ObservedObject(wrappedValue: userProfile)
        self._profileImage = profileImage
        self._localName = State(initialValue: localName)
        self._localHeadline = State(initialValue: localHeadline)
        self._localLocation = State(initialValue: localLocation)
        self._localLink = State(initialValue: localLink)
        self.onProfileUpdated = onProfileUpdated
        self.onProfileImageUpdated = onProfileImageUpdated
        self._localSystemLocation = State(initialValue: localSystemLocation)
    }
    
    func loadSettings() {
        if isInitialLoad {
            if !isProfileImageLoaded {
                isLoadingProfileImage = true
                if let profileImageURL = userProfile.profileImageURL {
                    if let cachedImage = ImageCache.shared.get(forKey: profileImageURL) {
                        profileImage = cachedImage
                        isProfileImageLoaded = true
                        isLoadingProfileImage = false
                        isLoading = false
                    } else {
                        FirebaseHelper.loadImageFromURL(urlString: profileImageURL) { uiImage, error in
                            if let error = error {
                                print("Error loading profile image:", error.localizedDescription)
                            } else if let uiImage = uiImage {
                                print("Profile image loaded successfully")
                                DispatchQueue.main.async {
                                    profileImage = uiImage
                                    ImageCache.shared.set(uiImage, forKey: profileImageURL)
                                    isProfileImageLoaded = true
                                }
                            } else {
                                print("Profile image not loaded, no error returned")
                            }
                            DispatchQueue.main.async {
                                isLoadingProfileImage = false
                                isLoading = false
                            }
                        }
                    }
                } else {
                    isLoadingProfileImage = false
                }
            }
            isInitialLoad = false
        }
    }
    
    func updateUserProfile(userRef: DocumentReference) {
        userRef.updateData([
            "profileImageURL": userProfile.profileImageURL ?? "",
            "name": userProfile.name,
            "headline": userProfile.headline,
            "location": userProfile.location,
            "link": userProfile.link,
            "systemLocation": userProfile.systemLocation,
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
        
        userProfile.name = localName
        userProfile.headline = localHeadline
        userProfile.location = localLocation
        userProfile.link = localLink
        userProfile.profileImageURL = localProfileImageURL
        profileImage = localProfileImage
        userProfile.systemLocation = localSystemLocation
        
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
                _ = onProfileImageUpdated?(localProfileImage ?? UIImage())
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
            .navigationBarTitle("Edit Profile", displayMode: .inline)
            .navigationBarItems(
                leading: cancelButton,
                trailing: saveButton
            )
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                DispatchQueue.main.async {
                    localName = userProfile.name
                    localHeadline = userProfile.headline
                    localLocation = userProfile.location
                    localLink = userProfile.link
                    localProfileImage = profileImage
                    localProfileImageURL = userProfile.profileImageURL
                    loadSettings()
                    hasChanges = false
                    updateSaveButtonState()
                }
            }
        }
    }
    
    private var profileImageSection: some View {
        Section {
            Button(action: {
                showImagePicker.toggle()
            }) {
                if let localProfileImage = localProfileImage {
                    Image(uiImage: localProfileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .clipShape(Circle())
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 75)
                            .foregroundColor(.clear)
                            .frame(width: 150, height: 150)

                        if !isProfileImageLoaded && isLoadingProfileImage {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "person.crop.circle.fill.badge.plus")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .id("placeholder")
                }
            }
            
            Button(action: {
                showImagePicker.toggle()
            }) {
                if localProfileImage != nil {
                    Text("Edit Photo")
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    Text("Add Photo")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .sheet(isPresented: $showImagePicker, onDismiss: handleImageChange) {
            ImagePicker(selectedImage: $localProfileImage, imageData: $profileImageData)
        }
    }
    
    func handleImageChange() {
        DispatchQueue.main.async {
            if localProfileImage != nil {
                hasChanges = true
                updateSaveButtonState()
            }
        }
    }
    
    private var nameSection: some View {
        Section(header: Text("Name")) {
            TextField("Your identity on the platform", text: $localName)
            .onChange(of: localName) { newValue in
                hasChanges = true
                updateSaveButtonState()
            }
        }
    }
    
    private var headlineSection: some View {
        Section(header: Text("Headline")) {
            let headlineBinding = Binding<String>(
                get: { localHeadline },
                set: { newValue in
                    var mutableValue = newValue
                    _ = Validator.validateStringLength(&mutableValue, maxLength: 60)
                    localHeadline = mutableValue
                }
            )
            TextField("Introduce yourself to the community", text: headlineBinding)
                .onChange(of: headlineBinding.wrappedValue) { newValue in
                    var mutableValue = newValue
                    _ = Validator.validateStringLength(&mutableValue, maxLength: 60)
                    headlineBinding.wrappedValue = mutableValue
                }
                .onChange(of: localHeadline) { newValue in
                    hasChanges = true
                    updateSaveButtonState()
                }
        }
    }
    
    private var locationSection: some View {
        Section(header: Text("Location")) {
            HStack {
                TextField("Find practitioners near you", text: $localLocation)
                // 5. Add a location button in the `locationSection` view.
                Button(action: {
                    // 6. Update the user's location string when the location button is pressed.
                    viewModel.requestLocation()
                }) {
                    Image(systemName: "location.fill")
                        .foregroundColor(.blue)
                }
            }
            .onChange(of: localLocation) { newValue in
                hasChanges = true
                updateSaveButtonState()
            }
        }
        .onChange(of: viewModel.currentLocation) { location in
            guard let location = location else { return }
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    print("Error geocoding location: \(error.localizedDescription)")
                } else if let placemark = placemarks?.first {
                    localLocation = "\(placemark.locality ?? ""), \(placemark.administrativeArea ?? "")"
                    localSystemLocation = "\(placemark.locality ?? ""), \(placemark.administrativeArea ?? "")"
                    hasChanges = true
                    updateSaveButtonState()
                }
            }
        }
    }
    
    private var linkSection: some View {
        Section(header: Text("Link")) {
            TextField("Primary website or social media", text: $localLink)
                .autocapitalization(.none)
            .onChange(of: localLink) { newValue in
                hasChanges = true
                updateSaveButtonState()
            }
        }
    }
    
    private func updateSaveButtonState() {
        if localName.isEmpty || localName == userProfile.name && localHeadline == userProfile.headline && localLocation == userProfile.location && localProfileImageURL == userProfile.profileImageURL && !hasChanges {
            isSaveDisabled = true
        } else {
            isSaveDisabled = false
        }
    }
    
    var cancelButton: some View {
        Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
        }
    }

    var saveButton: some View {
        Group {
            if isSavingProfile {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
            } else {
                Button(action: {
                    saveProfile()
                }) {
                    Text("Save")
                        .foregroundColor(isSaveDisabled ? .gray : .blue)
                }
                .disabled(localName.isEmpty)
                .disabled(isSaveDisabled)
            }
        }
    }
}
