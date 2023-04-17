import SwiftUI
import Photos
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(userProfile: UserProfile())
        .environmentObject(UserProfileData.previewData())
    }
}

struct SettingsView: View {
    @ObservedObject var userProfile: UserProfile
    @Environment(\.presentationMode) private var presentationMode
    @State private var showAlert: Bool = false
    @State private var errorMessage: String = ""
    @State private var showDatePicker = false
    @State private var isBirthdaySet = false
    @State private var credentialImage: UIImage?
    @State private var credentialImageData: Data?
    @State private var showImagePicker = false
    @State private var isLoadingCredentialImage: Bool = false
    @State private var isSavingProfile: Bool = false
    @State private var isLoading = false
    @State private var isInitialLoad = true
    @State private var isCredentialImageLoaded = false
    @State private var hasChanges = false
    @State private var isSaveDisabled = true
    @State private var localEmail: String = ""
    @State private var localPhone: String = ""
    @State private var localBirthday: Date = Date()
    @State private var localCredentialImage: UIImage?
    @State private var localCredentialImageURL: String?
    var onSettingsUpdated: (() -> Void)?
    
    func loadSettings() {
        if isInitialLoad {
            if !isCredentialImageLoaded {
                isLoadingCredentialImage = true
                if let credentialImageURL = userProfile.credentialImageURL {
                    if let cachedImage = ImageCache.shared.get(forKey: credentialImageURL) {
                        credentialImage = cachedImage
                        isCredentialImageLoaded = true
                        isLoadingCredentialImage = false
                        isLoading = false
                    } else {
                        FirebaseHelper.loadImageFromURL(urlString: credentialImageURL) { uiImage, error in
                            if let error = error {
                                print("Error loading credential image:", error.localizedDescription)
                            } else if let uiImage = uiImage {
                                print("Credential image loaded successfully")
                                DispatchQueue.main.async {
                                    credentialImage = uiImage
                                    ImageCache.shared.set(uiImage, forKey: credentialImageURL)
                                    isCredentialImageLoaded = true
                                }
                            } else {
                                print("Credential image not loaded, no error returned")
                            }
                            DispatchQueue.main.async {
                                isLoadingCredentialImage = false
                                isLoading = false
                            }
                        }
                    }
                } else {
                    isLoadingCredentialImage = false
                }
            }
            loadUserBirthday()
            isInitialLoad = false
        }
    }
    
    func loadUserBirthday() {
        if let user = Auth.auth().currentUser {
            let db = Firestore.firestore()
            let userRef = db.collection("users").document(user.uid)

            userRef.getDocument { document, error in
                if let document = document, document.exists {
                    if let birthday = document.data()?["birthday"] as? Timestamp {
                        DispatchQueue.main.async {
                            userProfile.birthday = birthday.dateValue()
                            localBirthday = birthday.dateValue()
                            isBirthdaySet = !Calendar.current.isDateInToday(userProfile.birthday)
                            hasChanges = false
                            updateSaveButtonState()
                        }
                    } else {
                        isBirthdaySet = false
                    }
                } else {
                    print("Error fetching user's birthday: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    func updateUserSettings(userRef: DocumentReference) {
        userRef.updateData([
            "credentialImageURL": userProfile.credentialImageURL ?? "",
            "email": userProfile.email,
            "phone": userProfile.phone,
            "birthday": userProfile.birthday
        ]) { error in
            if let error = error {
                errorMessage = "Error updating settings: \(error.localizedDescription)"
                showAlert.toggle()
            } else {
                if let credentialImageURL = userProfile.credentialImageURL {
                    FirebaseHelper.loadImageFromURL(urlString: credentialImageURL) { uiImage, error in
                        if let error = error {
                            print("Error loading credential image:", error.localizedDescription)
                        } else if let uiImage = uiImage {
                            print("Credential image loaded successfully")
                            DispatchQueue.main.async {
                                credentialImage = uiImage
                            }
                        } else {
                            print("Credential image not loaded, no error returned")
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
                    onSettingsUpdated?()
                    self.presentationMode.wrappedValue.dismiss()
                    isSavingProfile = false
                }
            }
        }
    }

    func saveProfile() {
        isSavingProfile = true
        
        userProfile.email = localEmail
        userProfile.phone = localPhone
        userProfile.birthday = localBirthday
        userProfile.credentialImageURL = localCredentialImageURL
        credentialImage = localCredentialImage
        
        if let user = Auth.auth().currentUser {
            let userRef = Firestore.firestore().collection("users").document(user.uid)
            let dispatchGroup = DispatchGroup()

            if let credentialImageData = credentialImageData {
                dispatchGroup.enter()
                FirebaseHelper.uploadImageToStorage(imageData: credentialImageData, imagePath: "credentialImages/\(user.uid).jpg") { result in
                    switch result {
                    case .success(let urlString):
                        userProfile.credentialImageURL = urlString
                    case .failure(let error):
                        errorMessage = "Error uploading credential image: \(error.localizedDescription)"
                        showAlert.toggle()
                    }
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {
                updateUserSettings(userRef: userRef)
            }
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                birthdaySection
                securitySection
                verificationSection
                logOutButton
            }
            .adaptsToKeyboard()
            .ignoresSafeArea(.keyboard)
            .gesture(DragGesture().onChanged({ _ in
                UIApplication.shared.endEditing()
            }))
            .navigationBarTitle("Settings", displayMode: .inline)
            .navigationBarItems(
                leading: cancelButton,
                trailing: saveButton
            )
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                DispatchQueue.main.async {
                    localEmail = userProfile.email
                    localPhone = userProfile.phone
                    localBirthday = userProfile.birthday
                    localCredentialImage = credentialImage
                    localCredentialImageURL = userProfile.credentialImageURL
                    loadSettings()
                    hasChanges = false
                    updateSaveButtonState()
                }
            }
        }
    }
    
    private var verificationSection: some View {
        Section(header: Text("Verification"), footer: Text("Become a verified practitioner by uploading an image of your certification.")) {
            if let credentialImage = credentialImage {
                Button(action: {
                    showImagePicker.toggle()
                }) {
                    Image(uiImage: localCredentialImage ?? credentialImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .clipped()
                }
            } else {
                Button(action: {
                    showImagePicker.toggle()
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 75)
                            .foregroundColor(.clear)
                            .frame(width: 150, height: 150)

                        if !isCredentialImageLoaded && isLoadingCredentialImage {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "doc.badge.plus")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }

            Button(action: {
                showImagePicker.toggle()
                hasChanges = true
                updateSaveButtonState()
            }) {
                if credentialImage != nil {
                    Text("Edit Credential")
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    Text("Add Credential")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $localCredentialImage, imageData: $credentialImageData)
        }
    }

    private var birthdaySection: some View {
        Section(header: Text("Birthday"), footer: Text("We use this to improve your experience and give you discounts.")) {
            if isBirthdaySet {
                Text("\(localBirthday, formatter: GlobalDefaults.dateFormatter)")
                    .foregroundColor(Color(.placeholderText))
            } else {
                Button(action: {
                    showDatePicker.toggle()
                }) {
                    Text("Add Birthday")
                }
                .onChange(of: localBirthday) { newDate in
                    if newDate != localBirthday {
                        localBirthday = newDate
                        isBirthdaySet = !Calendar.current.isDateInToday(localBirthday)
                        hasChanges = true
                        updateSaveButtonState()
                    }
                }
                .sheet(isPresented: $showDatePicker) {
                    VStack {
                        Text("Select Your Birthday")
                            .font(.headline)
                        DatePicker("", selection: $localBirthday, displayedComponents: .date)
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden()
                        Button(action: {
                            isBirthdaySet = true
                            showDatePicker = false
                        }) {
                            Text("Done")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.top)
                    }
                    .padding()
                }
            }
        }
    }

    private var securitySection: some View {
        Section(header: Text("Security"), footer: Text("We use this to secure your account and send you important updates.")) {
            TextField("Email", text: $localEmail)
                .autocapitalization(.none)
                .onChange(of: localEmail) { newValue in
                    localEmail = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                    hasChanges = true
                    updateSaveButtonState()
                }

            TextField("Phone", text: $localPhone)
                .onChange(of: localPhone) { newValue in
                    localPhone = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                    hasChanges = true
                    updateSaveButtonState()
                }
        }
    }
    
    private func updateSaveButtonState() {
        if localEmail == userProfile.email && localPhone == userProfile.phone && localBirthday == userProfile.birthday && localCredentialImageURL == userProfile.credentialImageURL && !hasChanges {
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
                .disabled(isSaveDisabled)
            }
        }
    }
    
    private var logOutButton: some View {
        Button(action: {
            try? Auth.auth().signOut()
        }, label: {
            Text("Log Out")
                .foregroundColor(.red)
        })
    }
}
