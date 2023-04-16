import SwiftUI
import Photos
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(userProfile: UserProfile(name: "", headline: "", location: "", link: "", profileImageURL: ""))
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
    @State private var showCredentialImagePicker = false
    @State private var isLoadingCredentialImage: Bool = false
    @State private var isSavingProfile: Bool = false
    @State private var isLoading = false
    @State private var isInitialLoad = true
    @State private var isCredentialImageLoaded = false
    @State private var hasChanges = false
    @State private var isSaveDisabled = true
    
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
                                print("Error loading profile image:", error.localizedDescription)
                            } else if let uiImage = uiImage {
                                print("Profile image loaded successfully")
                                DispatchQueue.main.async {
                                    credentialImage = uiImage
                                    ImageCache.shared.set(uiImage, forKey: credentialImageURL)
                                    isCredentialImageLoaded = true // Set the flag to true after loading the image
                                }
                            } else {
                                print("Profile image not loaded, no error returned")
                            }
                            DispatchQueue.main.async {
                                isLoadingCredentialImage = false // Set isLoadingCredentialImage to false after loading the image
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
                            isBirthdaySet = !Calendar.current.isDateInToday(userProfile.birthday)
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
            "email": userProfile.email,
            "phone": userProfile.phone,
            "birthday": userProfile.birthday,
            "credentialImageURL": userProfile.credentialImageURL ?? ""
        ]) { error in
            if let error = error {
                errorMessage = "Error updating account: \(error.localizedDescription)"
                showAlert.toggle()
            } else {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }

    func saveProfile() {
        isSavingProfile = true
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
        NavigationView {
            Form {
                birthdaySection
                securitySection
                verificationSection
                Button(action: {
                    try? Auth.auth().signOut()
                }, label: {
                    Text("Log Out")
                        .foregroundColor(.red)
                })
            }
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
            .onAppear(perform: loadSettings)
        }
    }

    private var birthdaySection: some View {
        Section(header: Text("Birthday"), footer: Text("We use this to improve your experience and give you discounts.")) {
            if isBirthdaySet {
                Text("\(userProfile.birthday, formatter: GlobalDefaults.dateFormatter)")
                    .foregroundColor(Color(.placeholderText))
            } else {
                Button(action: {
                    showDatePicker.toggle()
                }) {
                    Text("Add Birthday")
                }
                .onChange(of: userProfile.birthday) { _ in
                    isBirthdaySet = !Calendar.current.isDateInToday(userProfile.birthday)
                    hasChanges = true
                    updateSaveButtonState()
                }
                .sheet(isPresented: $showDatePicker) {
                    VStack {
                        Text("Select Your Birthday")
                            .font(.headline)
                        DatePicker("", selection: $userProfile.birthday, displayedComponents: .date)
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
            TextField("Email", text: $userProfile.email)
                .autocapitalization(.none)
                .onChange(of: userProfile.email) { newValue in
                    userProfile.email = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                    hasChanges = true
                    updateSaveButtonState()
                }

            TextField("Phone", text: $userProfile.phone)
                .onChange(of: userProfile.phone) { newValue in
                    userProfile.phone = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                    hasChanges = true
                    updateSaveButtonState()
                }
        }
    }
    
    private var verificationSection: some View {
        Section(header: Text("Verification"), footer: Text("Become a verified practitioner by uploading an image of your certification.")) {
            if let credentialImage = credentialImage {
                Button(action: {
                    showCredentialImagePicker.toggle()
                }) {
                    Image(uiImage: credentialImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .clipped()
                }
            } else {
                Button(action: {
                    showCredentialImagePicker.toggle()
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
                showCredentialImagePicker.toggle()
                hasChanges = true
                updateSaveButtonState()
            }) {
                if credentialImage != nil {
                    Text("Edit Photo")
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    Text("Add Photo")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .sheet(isPresented: $showCredentialImagePicker) {
            ImagePicker(selectedImage: $credentialImage, imageData: $credentialImageData)
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
                Button("Save") {
                    saveProfile()
                }
                .disabled(isSaveDisabled)
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
