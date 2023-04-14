import SwiftUI
import Photos
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView(userProfile: UserProfile())
        .environmentObject(AppData())
    }
}

struct EditProfileView: View {
    @ObservedObject var userProfile: UserProfile
    @Environment(\.presentationMode) private var presentationMode
    @State var userPhoto: UIImage? = nil
    @State private var userPhotoData: Data? = nil
    @State private var showImagePicker: Bool = false
    @State private var showAlert: Bool = false
    @State private var errorMessage: String = ""
    @State private var credentialImage: UIImage?
    @State private var credentialImageData: Data?
    @State private var showCredentialImagePicker = false
    @State private var showDatePicker = false
    @State private var isBirthdaySet = false
    var onProfilePhotoUpdated: ((UIImage) -> Void)?
    @State private var isLoadingUserPhoto: Bool = false
    @State private var isLoadingCredentialImage: Bool = false
    @State private var userName: String = ""
    @State private var userBio: String = ""
    @State private var userLocation: String = ""
    @State private var userWebsite: String = ""

    func saveProfile() {
        if let user = Auth.auth().currentUser {
            let userRef = Firestore.firestore().collection("users").document(user.uid)
            let dispatchGroup = DispatchGroup()
            
            if let credentialImageData = credentialImageData {
                dispatchGroup.enter()
                FirebaseHelper.uploadImageToStorage(imageData: credentialImageData, imagePath: "credentialImages/\(user.uid).jpg") { result in
                    switch result {
                    case .success(let urlString):
                        userProfile.userCredential = urlString
                    case .failure(let error):
                        errorMessage = "Error uploading credential image: \(error.localizedDescription)"
                        showAlert.toggle()
                    }
                    dispatchGroup.leave()
                }
            }
            
            if let profileImageData = userPhotoData {
                dispatchGroup.enter()
                FirebaseHelper.uploadImageToStorage(imageData: profileImageData, imagePath: "profileImages/\(user.uid).jpg") { result in
                    switch result {
                    case .success(let urlString):
                        userProfile.userProfileImage = urlString
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
    
    func updateUserProfile(userRef: DocumentReference) {
        userRef.updateData([
            "name": userProfile.name,
            "email": userProfile.email,
            "location": userProfile.location,
            "userName": userProfile.userName,
            "userEmail": userProfile.userEmail,
            "userLocation": userProfile.userLocation,
            "userPhoneNumber": userProfile.userPhoneNumber,
            "userBio": userProfile.userBio,
            "userVerification": userProfile.userVerification,
            "userCredential": userProfile.userCredential ?? "",
            "userProfileImage": userProfile.userProfileImage ?? "",
            "userWebsite": userProfile.userWebsite,
            "userBirthday": FirebaseHelper().dateFormatter.string(from: userProfile.userBirthday),
            "userJoined": FirebaseHelper().dateFormatter.string(from: userProfile.userJoined)
        ]) { error in
            if let error = error {
                errorMessage = "Error updating profile: \(error.localizedDescription)"
                showAlert.toggle()
            } else {
                if let credentialURL = userProfile.userCredential {
                    FirebaseHelper.loadImageFromURL(urlString: credentialURL) { (image: UIImage?) in
                        if let image = image {
                            credentialImage = image
                        }
                    }
                }
                
                if let profileImageURL = userProfile.userProfileImage {
                    userProfile.profileImageURL = profileImageURL // Set the @Published property
                }
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    // Function to load user and credential images
    func loadImages() {
        isLoadingUserPhoto = true
        isLoadingCredentialImage = true

        if let profileImageURL = userProfile.userProfileImage {
            FirebaseHelper.loadImageFromURL(urlString: profileImageURL) { image in
                if let image = image {
                    userPhoto = image
                }
                isLoadingUserPhoto = false
            }
        } else {
            isLoadingUserPhoto = false
        }
        
        if let credentialImageURL = userProfile.userCredential {
            FirebaseHelper.loadImageFromURL(urlString: credentialImageURL) { image in
                if let image = image {
                    credentialImage = image
                }
                isLoadingCredentialImage = false
            }
        } else {
            isLoadingCredentialImage = false
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                        VStack {
                            if let userPhoto = userPhoto {
                                Image(uiImage: userPhoto)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 150, height: 150)
                                    .clipShape(Circle())
                                    .frame(maxWidth: .infinity, alignment: .center)
                            } else if !isLoadingUserPhoto {
                                Image(systemName: "person.crop.circle.fill.badge.plus")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 150, height: 150)
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .sheet(isPresented: $showImagePicker) {
                                        ImagePicker(selectedImage: $userPhoto, imageData: $userPhotoData)
                                    }
                            }
                            
                            if isLoadingUserPhoto {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                    .scaleEffect(1.0)
                                    .frame(width: 150, height: 150)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }

                        }
                    Button(action: {
                        showImagePicker.toggle()
                    }) {
                        Text("Edit Photo")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .sheet(isPresented: $showImagePicker) {
                                ImagePicker(selectedImage: $userPhoto, imageData: $userPhotoData)
                            }
                    }
                }
                
                Section(header: Text("Profile")) {
                    TextField("Name", text: $userName)
                        .onChange(of: userProfile.userName) { newValue in
                            userProfile.userName = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                        }

                    TextEditor(text: $userBio)
                        .frame(height: 100)
                        .onChange(of: userProfile.userBio) { newValue in
                            if newValue.count > 160 {
                                userProfile.userBio = String(newValue.prefix(160))
                            }
                        }

                        .onChange(of: userProfile.userBio) { newValue in
                            userProfile.userBio = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                        .overlay(
                            Group {
                                if userProfile.userBio.isEmpty {
                                    Text("Bio")
                                        .foregroundColor(Color(.placeholderText))
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                        .padding(.top, 8)
                                        .padding(.leading, 4)
                                }
                            }
                        )
                    
                    TextField("Location", text: $userLocation)
                        .onChange(of: userProfile.userLocation) { newValue in
                            userProfile.userLocation = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                    
                    TextField("Website", text: $userWebsite)
                        .autocapitalization(.none)
                        .onChange(of: userProfile.userWebsite) { newValue in
                            userProfile.userWebsite = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                    
                    Button(action: {
                        showDatePicker.toggle()
                    }) {
                        HStack {
                            Text("Birthday")
                                .foregroundColor(Color.secondary)
                            Spacer()
                            if isBirthdaySet {
                                Text("\(userProfile.userBirthday, formatter: FirebaseHelper().dateFormatter)")
                                    .foregroundColor(Color(.placeholderText))
                            } else {
                                Text("Set Date")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .onAppear {
                        isBirthdaySet = !Calendar.current.isDateInToday(userProfile.userBirthday)
                    }
                    .onChange(of: userProfile.userBirthday) { _ in
                        isBirthdaySet = !Calendar.current.isDateInToday(userProfile.userBirthday)
                    }
                    .sheet(isPresented: $showDatePicker) {
                        VStack {
                            Text("Select Your Birthday")
                                .font(.headline)
                            DatePicker("", selection: $userProfile.userBirthday, displayedComponents: .date)
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
                
                Section(header: Text("Verification"), footer: Text("Earn your verified practitioner badge by uploading an image of your certification.")) {
                    Button(action: { showCredentialImagePicker.toggle() }) {
                            if let credentialImage = credentialImage {
                                Image(uiImage: credentialImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 150, height: 150)
                                    .clipped()
                                    .frame(maxWidth: .infinity, alignment: .center)
                            } else if !isLoadingCredentialImage {
                                Image(systemName: "doc.badge.plus")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 150, height: 150)
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            
                            if isLoadingCredentialImage {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                    .scaleEffect(1.0)
                                    .frame(width: 150, height: 150)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                    }
                    Button(action: {
                        showCredentialImagePicker.toggle()
                    }) {
                        Text("Upload Credential")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .sheet(isPresented: $showCredentialImagePicker) {
                                ImagePicker(selectedImage: $credentialImage, imageData: $credentialImageData)
                            }
                    }
                }
            }
            
            .scrollDismissesKeyboard(.immediately)
            .ignoresSafeArea(.keyboard)

            .navigationBarTitle("Edit Profile", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                userProfile.userName = userName
                userProfile.userBio = userBio
                userProfile.userLocation = userLocation
                userProfile.userWebsite = userWebsite
                saveProfile()
                presentationMode.wrappedValue.dismiss()
            })
        }
        .onAppear {
            loadImages()
            userName = userProfile.userName
            userBio = userProfile.userBio
            userLocation = userProfile.userLocation
            userWebsite = userProfile.userWebsite
        }
    }
}
