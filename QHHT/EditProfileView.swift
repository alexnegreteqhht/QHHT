import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseAppCheck
import FirebaseFirestore

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView(userProfile: UserProfile())
        .environmentObject(AppData())
    }
}

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d, yyyy"
    return formatter
}()

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
    
    func saveProfile() {
        if let user = Auth.auth().currentUser {
            let db = Firestore.firestore()
            let storage = Storage.storage()
            let userRef = db.collection("users").document(user.uid)
            
            let dispatchGroup = DispatchGroup()
            
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
            
            if let profileImageData = userPhotoData {
                dispatchGroup.enter()
                let storageRef = storage.reference().child("profileImages/\(user.uid).jpg")
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                
                storageRef.putData(profileImageData, metadata: metadata) { metadata, error in
                    if let error = error {
                        errorMessage = "Error uploading profile image: \(error.localizedDescription)"
                        showAlert.toggle()
                    } else {
                        storageRef.downloadURL { url, error in
                            if let error = error {
                                errorMessage = "Error retrieving profile image URL: \(error.localizedDescription)"
                                showAlert.toggle()
                            } else if let url = url {
                                userProfile.userProfileImage = url.absoluteString
                            }
                            dispatchGroup.leave()
                        }
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                updateUserProfile(userRef: userRef)
            }
        }
    }
    
    func loadImageFromURL(urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
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
            "userBirthday": dateFormatter.string(from: userProfile.userBirthday),
            "userJoined": dateFormatter.string(from: userProfile.userJoined)
        ]) { error in
            if let error = error {
                errorMessage = "Error updating profile: \(error.localizedDescription)"
                showAlert.toggle()
            } else {
                if let credentialURL = userProfile.userCredential {
                    loadImageFromURL(urlString: credentialURL) { image in
                        if let image = image {
                            credentialImage = image
                        }
                    }
                }

                if let profileImageURL = userProfile.userProfileImage {
                    userProfile.profileImageURL = profileImageURL // Set the @Published property
                }
            }
        }
    }


    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        Button(action: { showImagePicker.toggle() }) {
                            if let userPhoto = userPhoto {
                                Image(uiImage: userPhoto)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 150, height: 150)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.crop.circle.fill.badge.plus")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 150, height: 150)
                                    .foregroundColor(.gray)
                            }
                        }
                        .sheet(isPresented: $showImagePicker) {
                            ImagePicker(selectedImage: $userPhoto, imageData: $userPhotoData)
                        }

                        Spacer()
                    }
                }
                    Section(header: Text("Profile")) {
                        TextField("Name", text: $userProfile.userName)
                        .onChange(of: userProfile.userName) { newValue in
                            userProfile.userName = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                        .gesture(
                            DragGesture().onChanged { _ in
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }
                        )
                        
                        TextEditor(text: $userProfile.userBio)
                        .frame(height: 100)
                        .onChange(of: userProfile.userBio) { newValue in
                            if newValue.count > 160 {
                                userProfile.userBio = String(newValue.prefix(160))
                            }
                        }
                        .gesture(
                            DragGesture()
                                .onChanged { _ in
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                }
                        )
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
                        
                    TextField("Location", text: $userProfile.userLocation)
                    .gesture(
                        DragGesture().onChanged { _ in
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    )
                    .onChange(of: userProfile.userLocation) { newValue in
                        userProfile.userLocation = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    TextField("Website", text: $userProfile.userWebsite)
                    .autocapitalization(.none)
                    .gesture(
                        DragGesture().onChanged { _ in
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    )
                    .onChange(of: userProfile.userWebsite) { newValue in
                        userProfile.userWebsite = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    Button(action: {
                        showDatePicker.toggle()
                    }) {
                        HStack {
                            Text("Birthday")
                                .foregroundColor(Color(.label))
                                .gesture(
                                    DragGesture().onChanged { _ in
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    }
                                )
                            Spacer()
                            if isBirthdaySet {
                                Text("\(userProfile.userBirthday, formatter: dateFormatter)")
                                    .foregroundColor(.gray) // Date text should be gray if birthday is set
                            } else {
                                Text("Set Date")
                                    .foregroundColor(.blue) // "Set Date" text should be blue if birthday is not set
                            }
                        }
                    }
                    
                    .onAppear {
                        // Check if the user's birthday has been set.
                        isBirthdaySet = !Calendar.current.isDateInToday(userProfile.userBirthday)
                    }
                    .onChange(of: userProfile.userBirthday) { _ in
                        // Update isBirthdaySet when the user selects a birthday.
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
                
                Section(header: Text("Contact")) {
                    TextField("Email", text: $userProfile.userEmail)
                    .autocapitalization(.none)
                    .gesture(
                        DragGesture().onChanged { _ in
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    )
                    .onChange(of: userProfile.userEmail) { newValue in
                        userProfile.userEmail = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    TextField("Phone", text: $userProfile.userPhoneNumber)
                    .gesture(
                        DragGesture().onChanged { _ in
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    )
                    .onChange(of: userProfile.userPhoneNumber) { newValue in
                        userProfile.userPhoneNumber = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                }
                
                Section(header: Text("Verification")) {
                    Button(action: { showCredentialImagePicker = true }) {
                        if let credentialImage = credentialImage {
                            Image(uiImage: credentialImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 150, height: 150)
                                .clipped()
                        } else {
                            Image(systemName: "doc.badge.plus")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 150, height: 150)
                                .foregroundColor(.gray)
                        }
                    }

                    Button(action: {
                        showCredentialImagePicker = true
                    }) {
                        Text("Upload Credential Image")
                            .foregroundColor(.blue)
                    }
                    .sheet(isPresented: $showCredentialImagePicker) {
                        ImagePicker(selectedImage: $credentialImage, imageData: $credentialImageData)
                    }
                    
                    if userProfile.userVerification != "" {
                        Text("Status: \(userProfile.userVerification)")
                            .font(.callout)
                            .foregroundColor(.gray)
                    } else {
                        Text("Earn your verified practitioner badge by uploading an image of your certification. Image must match the name on your account.")
                            .font(.callout)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationBarTitle("Edit Profile", displayMode: .inline)
            .navigationBarItems(
                leading:
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    },
                trailing:
                    Button("Save") {
                        if let profileImageURL = userProfile.userProfileImage {
                            userProfile.profileImageURL = profileImageURL
                        }
                        
                        presentationMode.wrappedValue.dismiss()
                        saveProfile()
                        if let userPhoto = userPhoto, let onUpdate = onProfilePhotoUpdated {
                            onUpdate(userPhoto)
                        }
                    }
            )
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            
            .onAppear {


                loadImageFromURL(urlString: userProfile.userCredential ?? "") { image in
                    if let image = image {
                        credentialImage = image
                    }
                    loadImageFromURL(urlString: userProfile.userProfileImage ?? "") { image in
                        if let image = image {
                            userPhoto = image
                        }
                    }
                }
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var imageData: Data?
    @Environment(\.presentationMode) private var presentationMode

    func makeCoordinator() -> Coordinator {
        Coordinator(self, imageData: $imageData)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {

    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        @Binding var imageData: Data?

        init(_ parent: ImagePicker, imageData: Binding<Data?>) {
            self.parent = parent
            _imageData = imageData
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = uiImage
                if let data = uiImage.jpegData(compressionQuality: 1.0) {
                    imageData = data
                }
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
