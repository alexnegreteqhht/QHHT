import SwiftUI
import Firebase

struct EditProfileView: View {
    @ObservedObject var userProfile: UserProfile
    @Environment(\.presentationMode) var presentationMode
    @State private var userPhoto: UIImage? = nil
    @State private var userPhotoData: Data? = nil
    @State private var showImagePicker: Bool = false
    @State private var showAlert: Bool = false
    @State private var errorMessage: String = ""
    @State private var credentialImage: UIImage?
    @State private var credentialImageData: Data?
    @State private var showCredentialImagePicker = false

    func saveProfile() {
        // Save updated profile data to Firestore
        // Validate and process the data before saving
        if let user = Auth.auth().currentUser {
            let db = Firestore.firestore()
            let userRef = db.collection("users").document(user.uid)
            
            userRef.updateData([
                "fullName": userProfile.name,
                "emailAddress": userProfile.email,
                "location": userProfile.location,
                "userName": userProfile.userName,
                "userEmail": userProfile.userEmail,
                "userLocation": userProfile.userLocation,
                "phoneNumber": userProfile.userPhoneNumber,
                "bio": userProfile.userBio,
                "userType": userProfile.userType,
                "credentials": userProfile.userCredentials,
                "userPhotoURL": userProfile.userPhotoURL
            ]) { error in
                if let error = error {
                    errorMessage = "Error updating profile: \(error.localizedDescription)"
                    showAlert.toggle()
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Spacer()
                        Button(action: { showImagePicker.toggle() }) {
                            if let userPhoto = userPhoto {
                                Image(uiImage: userPhoto)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 150, height: 150)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.crop.circle.fill")
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
                
                Section(header: Text("Profile Information")) {
                    TextField("User Name", text: $userProfile.userName)
                    TextField("User Location", text: $userProfile.userLocation)
                    TextEditor(text: $userProfile.userBio)
                        .frame(height: 100)
                        .onChange(of: userProfile.userBio) { newValue in
                            if newValue.count > 160 {
                                userProfile.userBio = String(newValue.prefix(160))
                            }
                        }
                }
                
                Section(header: Text("Contact Information")) {
                    TextField("User Email", text: $userProfile.userEmail)
                    TextField("Phone Number", text: $userProfile.userPhoneNumber)
                }
                
                Section(header: Text("Practitioner Verification")) {
                    if let image = credentialImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                    } else {
                        Image(systemName: "doc.badge.plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .foregroundColor(.gray)
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

                    Text("Verification Status: \(userProfile.userType)")
                        .font(.callout)
                        .foregroundColor(.gray)
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
                        saveProfile()
                    }
            )
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var imageData: Data?
    @Environment(\.presentationMode) var presentationMode

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
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

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = uiImage
                parent.imageData = uiImage.jpegData(compressionQuality: 1.0)
            }

            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
