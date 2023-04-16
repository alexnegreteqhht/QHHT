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
    
    func loadSettings() {
        isLoadingCredentialImage = true
        if let credentialImageURL = userProfile.credentialImageURL {
            FirebaseHelper.loadImageFromURL(urlString: credentialImageURL) { image in
                if let image = image {
                    credentialImage = image
                }
                isLoadingCredentialImage = false
            }
        } else {
            isLoadingCredentialImage = false
        }
        loadUserBirthday()
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
                }
            TextField("Phone", text: $userProfile.phone)
                .onChange(of: userProfile.phone) { newValue in
                    userProfile.phone = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                }
        }
    }
    
    private var verificationSection: some View {
        Section {
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

                        if !isLoadingCredentialImage {
                            Image(systemName: "doc.badge.plus")
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
                showCredentialImagePicker.toggle()
            }) {
                if credentialImage != nil {
                    Text("Edit Photo")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .sheet(isPresented: $showCredentialImagePicker) {
                            ImagePicker(selectedImage: $credentialImage, imageData: $credentialImageData)
                        }
                } else {
                    Text("Add Photo")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .sheet(isPresented: $showCredentialImagePicker) {
                            ImagePicker(selectedImage: $credentialImage, imageData: $credentialImageData)
                        }
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
            }
        }
    }
}
