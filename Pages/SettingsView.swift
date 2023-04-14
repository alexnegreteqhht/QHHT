import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(userProfile: UserProfile(id: "", userName: "", userBio: "", userProfileImage: ""))
            .environmentObject(AppData())
    }
}

struct SettingsView: View {
    @ObservedObject var userProfile: UserProfile
    @Environment(\.presentationMode) var presentationMode
    @State private var showAlert: Bool = false
    @State private var errorMessage: String = ""
    @State private var showDatePicker = false
    @State private var isBirthdaySet = false
    @State private var credentialImage: UIImage?
    @State private var credentialImageData: Data?
    @State private var showCredentialImagePicker = false
    @State private var isLoadingCredentialImage: Bool = false
    @State private var isSavingProfile: Bool = false
    
    func loadUserBirthday() {
        print("loadUserBirthday() called")
        if let user = Auth.auth().currentUser {
            let db = Firestore.firestore()
            let userRef = db.collection("users").document(user.uid)

            userRef.getDocument { document, error in
                if let document = document, document.exists {
                    if let userBirthday = document.data()?["userBirthday"] as? Timestamp {
                        DispatchQueue.main.async { // Add this line
                            userProfile.userBirthday = userBirthday.dateValue()
                            isBirthdaySet = !Calendar.current.isDateInToday(userProfile.userBirthday)
                            print("User's birthday loaded: \(userProfile.userBirthday)")
                        } // Add this line
                    } else {
                        // Set isBirthdaySet to false if there's no birthday in the database
                        isBirthdaySet = false
                    }
                } else {
                    print("Error fetching user's birthday: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    func loadCredentialImage() {
        if let userCredential = userProfile.userCredential, let url = URL(string: userCredential) {
            isLoadingCredentialImage = true
            let storageRef = Storage.storage().reference(forURL: url.absoluteString)
            
            storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                isLoadingCredentialImage = false
                if let error = error {
                    print("Error loading credential image: \(error.localizedDescription)")
                } else if let data = data {
                    credentialImage = UIImage(data: data)
                }
            }
        }
    }

    
    func saveProfile() {
        isSavingProfile = true
        if let user = Auth.auth().currentUser {
            let db = Firestore.firestore()
            let storage = Storage.storage()
            let userRef = db.collection("users").document(user.uid)
            
            let dispatchGroup = DispatchGroup()
            
            userRef.updateData([
                "userEmail": userProfile.userEmail,
                "userPhoneNumber": userProfile.userPhoneNumber,
                "userBirthday": userProfile.userBirthday
            ]) { error in
                if let error = error {
                    errorMessage = "Error updating account: \(error.localizedDescription)"
                    showAlert.toggle()
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            
            if let credentialImageData = credentialImageData {
                dispatchGroup.enter()
                let storageRef = storage.reference().child("credentialImages/\(user.uid).jpg")
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"

                storageRef.putData(credentialImageData, metadata: metadata) { metadata, error in
                    if let error = error {
                        errorMessage = "Error uploading credential image: \(error.localizedDescription)"
                        showAlert.toggle()
                    } else {
                        storageRef.downloadURL { url, error in
                            if let error = error {
                                errorMessage = "Error retrieving credential image URL: \(error.localizedDescription)"
                                showAlert.toggle()
                            } else if let url = url {
                                userProfile.userCredential = url.absoluteString
                            }
                            dispatchGroup.leave()
                        }
                    }
                }
            }

            dispatchGroup.notify(queue: .main) {
                userRef.updateData([
                    "userCredential": userProfile.userCredential ?? ""
                ]) { error in
                    if let error = error {
                        errorMessage = "Error updating user credential: \(error.localizedDescription)"
                        showAlert.toggle()
                    }
                }
                isSavingProfile = false
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Birthday"), footer: Text("We use this to improve your experience and give you discounts.")) {
                    if isBirthdaySet {
                        Text("\(userProfile.userBirthday, formatter: FirebaseHelper().dateFormatter)")
                            .foregroundColor(Color(.placeholderText))
                    } else {
                        Button(action: {
                            showDatePicker.toggle()
                        }) {
                            Text("Add Birthday")
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
                }
                
                Section(header: Text("Security"), footer: Text("We use this to secure your account and give you updates.")) {
                TextField("Email", text: $userProfile.userEmail)
                    .autocapitalization(.none)
                    .onChange(of: userProfile.userEmail) { newValue in
                        userProfile.userEmail = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                TextField("Phone", text: $userProfile.userPhoneNumber)
                    .onChange(of: userProfile.userPhoneNumber) { newValue in
                        userProfile.userPhoneNumber = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                }
                
                Section(header: Text("Verification"), footer: Text("Become a verified practitioner by uploading an image of your certification.")) {
                    Button(action: { showCredentialImagePicker.toggle() }) {
                        ZStack {
                            if let credentialImage = credentialImage {
                                Image(uiImage: credentialImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 150, height: 150)
                                    .clipped()
                            } else if !isLoadingCredentialImage {
                                Image(systemName: "doc.badge.plus")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 150, height: 150)
                                    .foregroundColor(.gray)
                            }

                            if isLoadingCredentialImage {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                    .scaleEffect(1.0)
                                    .frame(width: 150, height: 150)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
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
            
            .ignoresSafeArea(.keyboard)
            .gesture(DragGesture().onChanged({ _ in
                UIApplication.shared.endEditing()
            }))
                
                // Last Login
                
                //                Text("Joined: \(userProfile.userJoined, formatter: FirebaseHelper().dateFormatter)")
                
//                Button(action: {
//                    try? Auth.auth().signOut()
//                }, label: {
//                    Text("Log Out")
//                        .foregroundColor(.red)
//                })
//                .padding()
//
//                Spacer()
//            }
            .navigationBarTitle("Settings", displayMode: .inline)
            
            .navigationBarItems(
                leading:
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    },
                trailing:
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
            )
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
        
        .onAppear {
            loadCredentialImage()
            loadUserBirthday()
        }
    }
}
