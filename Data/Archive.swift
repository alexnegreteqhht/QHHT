//import SwiftUI
//import Firebase
//import FirebaseAuth
//import FirebaseStorage
//import FirebaseAppCheck
//import FirebaseFirestore
//
//struct EditProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditProfileView(userProfile: UserProfile())
//        .environmentObject(AppData())
//    }
//}
//
//let dateFormatter: DateFormatter = {
//    let formatter = DateFormatter()
//    formatter.dateFormat = "MMM d, yyyy"
//    return formatter
//}()
//
//struct EditProfileView: View {
//    @ObservedObject var userProfile: UserProfile
//    @Environment(\.presentationMode) private var presentationMode
//    @State var userPhoto: UIImage? = nil
//    @State private var userPhotoData: Data? = nil
//    @State private var showImagePicker: Bool = false
//    @State private var showAlert: Bool = false
//    @State private var errorMessage: String = ""
//    @State private var credentialImage: UIImage?
//    @State private var credentialImageData: Data?
//    @State private var showCredentialImagePicker = false
//    @State private var showDatePicker = false
//    @State private var isBirthdaySet = false
//    var onProfilePhotoUpdated: ((UIImage) -> Void)?
//
//    func saveProfile() {
//        if let user = Auth.auth().currentUser {
//            let db = Firestore.firestore()
//            let storage = Storage.storage()
//            let userRef = db.collection("users").document(user.uid)
//
//            let dispatchGroup = DispatchGroup()
//
//            if let credentialImageData = credentialImageData {
//                dispatchGroup.enter()
//                let storageRef = storage.reference().child("credentialImages/\(user.uid).jpg")
//                let metadata = StorageMetadata()
//                metadata.contentType = "image/jpeg"
//
//                storageRef.putData(credentialImageData, metadata: metadata) { metadata, error in
//                    if let error = error {
//                        errorMessage = "Error uploading credential image: \(error.localizedDescription)"
//                        showAlert.toggle()
//                    } else {
//                        storageRef.downloadURL { url, error in
//                            if let error = error {
//                                errorMessage = "Error retrieving credential image URL: \(error.localizedDescription)"
//                                showAlert.toggle()
//                            } else if let url = url {
//                                userProfile.userCredential = url.absoluteString
//                            }
//                            dispatchGroup.leave()
//                        }
//                    }
//                }
//            }
//
//            if let profileImageData = userPhotoData {
//                dispatchGroup.enter()
//                let storageRef = storage.reference().child("profileImages/\(user.uid).jpg")
//                let metadata = StorageMetadata()
//                metadata.contentType = "image/jpeg"
//
//                storageRef.putData(profileImageData, metadata: metadata) { metadata, error in
//                    if let error = error {
//                        errorMessage = "Error uploading profile image: \(error.localizedDescription)"
//                        showAlert.toggle()
//                    } else {
//                        storageRef.downloadURL { url, error in
//                            if let error = error {
//                                errorMessage = "Error retrieving profile image URL: \(error.localizedDescription)"
//                                showAlert.toggle()
//                            } else if let url = url {
//                                userProfile.userProfileImage = url.absoluteString
//                            }
//                            dispatchGroup.leave()
//                        }
//                    }
//                }
//            }
//
//            dispatchGroup.notify(queue: .main) {
//                updateUserProfile(userRef: userRef)
//            }
//        }
//    }
//
//    func loadImageFromURL(urlString: String, completion: @escaping (UIImage?) -> Void) {
//        guard let url = URL(string: urlString) else {
//            completion(nil)
//            return
//        }
//
//        URLSession.shared.dataTask(with: url) { data, _, _ in
//            if let data = data, let image = UIImage(data: data) {
//                DispatchQueue.main.async {
//                    completion(image)
//                }
//            } else {
//                DispatchQueue.main.async {
//                    completion(nil)
//                }
//            }
//        }.resume()
//    }
//
//    func updateUserProfile(userRef: DocumentReference) {
//        userRef.updateData([
//            "name": userProfile.name,
//            "email": userProfile.email,
//            "location": userProfile.location,
//            "userName": userProfile.userName,
//            "userEmail": userProfile.userEmail,
//            "userLocation": userProfile.userLocation,
//            "userPhoneNumber": userProfile.userPhoneNumber,
//            "userBio": userProfile.userBio,
//            "userVerification": userProfile.userVerification,
//            "userCredential": userProfile.userCredential ?? "",
//            "userProfileImage": userProfile.userProfileImage ?? "",
//            "userWebsite": userProfile.userWebsite,
//            "userBirthday": dateFormatter.string(from: userProfile.userBirthday),
//            "userJoined": dateFormatter.string(from: userProfile.userJoined)
//        ]) { error in
//            if let error = error {
//                errorMessage = "Error updating profile: \(error.localizedDescription)"
//                showAlert.toggle()
//            } else {
//                if let credentialURL = userProfile.userCredential {
//                    loadImageFromURL(urlString: credentialURL) { image in
//                        if let image = image {
//                            credentialImage = image
//                        }
//                    }
//                }
//
//                if let profileImageURL = userProfile.userProfileImage {
//                    userProfile.profileImageURL = profileImageURL // Set the @Published property
//                }
//            }
//        }
//    }
//
//
//    var body: some View {
//        NavigationStack {
//            Form {
//                Section {
//                    HStack {
//                        Spacer()
//                        Button(action: { showImagePicker.toggle() }) {
//                            if let userPhoto = userPhoto {
//                                Image(uiImage: userPhoto)
//                                    .resizable()
//                                    .scaledToFill()
//                                    .frame(width: 150, height: 150)
//                                    .clipShape(Circle())
//                            } else {
//                                Image(systemName: "person.crop.circle.fill.badge.plus")
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(width: 150, height: 150)
//                                    .foregroundColor(.gray)
//                            }
//                        }
//                        .sheet(isPresented: $showImagePicker) {
//                            ImagePicker(selectedImage: $userPhoto, imageData: $userPhotoData)
//                        }
//
//                        Spacer()
//                    }
//                }
//                    Section(header: Text("Profile")) {
//                        TextField("Name", text: $userProfile.userName)
//                        .onChange(of: userProfile.userName) { newValue in
//                            userProfile.userName = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
//                        }
//                        .gesture(
//                            DragGesture().onChanged { _ in
//                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//                            }
//                        )
//
//                        TextEditor(text: $userProfile.userBio)
//                        .frame(height: 100)
//                        .onChange(of: userProfile.userBio) { newValue in
//                            if newValue.count > 160 {
//                                userProfile.userBio = String(newValue.prefix(160))
//                            }
//                        }
//                        .gesture(
//                            DragGesture()
//                                .onChanged { _ in
//                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//                                }
//                        )
//                        .onChange(of: userProfile.userBio) { newValue in
//                            userProfile.userBio = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
//                        }
//                        .overlay(
//                            Group {
//                                if userProfile.userBio.isEmpty {
//                                    Text("Bio")
//                                        .foregroundColor(Color(.placeholderText))
//                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
//                                        .padding(.top, 8)
//                                        .padding(.leading, 4)
//                                }
//                            }
//                        )
//
//                    TextField("Location", text: $userProfile.userLocation)
//                    .gesture(
//                        DragGesture().onChanged { _ in
//                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//                        }
//                    )
//                    .onChange(of: userProfile.userLocation) { newValue in
//                        userProfile.userLocation = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
//                    }
//                    TextField("Website", text: $userProfile.userWebsite)
//                    .autocapitalization(.none)
//                    .gesture(
//                        DragGesture().onChanged { _ in
//                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//                        }
//                    )
//                    .onChange(of: userProfile.userWebsite) { newValue in
//                        userProfile.userWebsite = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
//                    }
//                    Button(action: {
//                        showDatePicker.toggle()
//                    }) {
//                        HStack {
//                            Text("Birthday")
//                                .foregroundColor(Color(.label))
//                                .gesture(
//                                    DragGesture().onChanged { _ in
//                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//                                    }
//                                )
//                            Spacer()
//                            if isBirthdaySet {
//                                Text("\(userProfile.userBirthday, formatter: dateFormatter)")
//                                    .foregroundColor(.gray) // Date text should be gray if birthday is set
//                            } else {
//                                Text("Set Date")
//                                    .foregroundColor(.blue) // "Set Date" text should be blue if birthday is not set
//                            }
//                        }
//                    }
//
//                    .onAppear {
//                        // Check if the user's birthday has been set.
//                        isBirthdaySet = !Calendar.current.isDateInToday(userProfile.userBirthday)
//                    }
//                    .onChange(of: userProfile.userBirthday) { _ in
//                        // Update isBirthdaySet when the user selects a birthday.
//                        isBirthdaySet = !Calendar.current.isDateInToday(userProfile.userBirthday)
//                    }
//                    .sheet(isPresented: $showDatePicker) {
//                        VStack {
//                            Text("Select Your Birthday")
//                                .font(.headline)
//                            DatePicker("", selection: $userProfile.userBirthday, displayedComponents: .date)
//                                .datePickerStyle(WheelDatePickerStyle())
//                                .labelsHidden()
//                            Button(action: {
//                                isBirthdaySet = true
//                                showDatePicker = false
//                            }) {
//                                Text("Done")
//                                    .padding()
//                                    .background(Color.blue)
//                                    .foregroundColor(.white)
//                                    .cornerRadius(10)
//                            }
//                            .padding(.top)
//                        }
//                        .padding()
//                    }
//
//                }
//
//                Section(header: Text("Contact")) {
//                    TextField("Email", text: $userProfile.userEmail)
//                    .autocapitalization(.none)
//                    .gesture(
//                        DragGesture().onChanged { _ in
//                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//                        }
//                    )
//                    .onChange(of: userProfile.userEmail) { newValue in
//                        userProfile.userEmail = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
//                    }
//                    TextField("Phone", text: $userProfile.userPhoneNumber)
//                    .gesture(
//                        DragGesture().onChanged { _ in
//                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//                        }
//                    )
//                    .onChange(of: userProfile.userPhoneNumber) { newValue in
//                        userProfile.userPhoneNumber = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
//                    }
//                }
//
//                Section(header: Text("Verification")) {
//                    Button(action: { showCredentialImagePicker = true }) {
//                        if let credentialImage = credentialImage {
//                            Image(uiImage: credentialImage)
//                                .resizable()
//                                .scaledToFill()
//                                .frame(width: 150, height: 150)
//                                .clipped()
//                        } else {
//                            Image(systemName: "doc.badge.plus")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 150, height: 150)
//                                .foregroundColor(.gray)
//                        }
//                    }
//
//                    Button(action: {
//                        showCredentialImagePicker = true
//                    }) {
//                        Text("Upload Credential Image")
//                            .foregroundColor(.blue)
//                    }
//                    .sheet(isPresented: $showCredentialImagePicker) {
//                        ImagePicker(selectedImage: $credentialImage, imageData: $credentialImageData)
//                    }
//
//                    if userProfile.userVerification != "" {
//                        Text("Status: \(userProfile.userVerification)")
//                            .font(.callout)
//                            .foregroundColor(.gray)
//                    } else {
//                        Text("Earn your verified practitioner badge by uploading an image of your certification. Image must match the name on your account.")
//                            .font(.callout)
//                            .foregroundColor(.gray)
//                    }
//                }
//            }
//            .navigationBarTitle("Edit Profile", displayMode: .inline)
//            .navigationBarItems(
//                leading:
//                    Button("Cancel") {
//                        presentationMode.wrappedValue.dismiss()
//                    },
//                trailing:
//                    Button("Save") {
//                        if let profileImageURL = userProfile.userProfileImage {
//                            userProfile.profileImageURL = profileImageURL
//                        }
//
//                        presentationMode.wrappedValue.dismiss()
//                        saveProfile()
//                        if let userPhoto = userPhoto, let onUpdate = onProfilePhotoUpdated {
//                            onUpdate(userPhoto)
//                        }
//                    }
//            )
//            .alert(isPresented: $showAlert) {
//                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
//            }
//
//            .onAppear {
//
//
//                loadImageFromURL(urlString: userProfile.userCredential ?? "") { image in
//                    if let image = image {
//                        credentialImage = image
//                    }
//                    loadImageFromURL(urlString: userProfile.userProfileImage ?? "") { image in
//                        if let image = image {
//                            userPhoto = image
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
//
//struct ImagePicker: UIViewControllerRepresentable {
//    @Binding var selectedImage: UIImage?
//    @Binding var imageData: Data?
//    @Environment(\.presentationMode) private var presentationMode
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self, imageData: $imageData)
//    }
//
//    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
//        let picker = UIImagePickerController()
//        picker.delegate = context.coordinator
//        return picker
//    }
//
//    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
//
//    }
//
//    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
//        let parent: ImagePicker
//        @Binding var imageData: Data?
//
//        init(_ parent: ImagePicker, imageData: Binding<Data?>) {
//            self.parent = parent
//            _imageData = imageData
//        }
//
//        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//            if let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
//                parent.selectedImage = uiImage
//                if let data = uiImage.jpegData(compressionQuality: 1.0) {
//                    imageData = data
//                }
//            }
//            parent.presentationMode.wrappedValue.dismiss()
//        }
//    }
//}


//import SwiftUI
//import Firebase
//import FirebaseFirestore
//import Combine
//
//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileView()
//            .environmentObject(AppData())
//    }
//}
//
//struct ProfileView: View {
//    @EnvironmentObject var appData: AppData
//    @ObservedObject var userProfile = UserProfile()
//    @State private var showEditProfile = false
//    @State private var showSettings = false
//    @State private var tempProfileImage: UIImage? = nil
//    @State private var hasProfileImageLoaded = false
//    @State private var isContentLoaded = false
//
//    private let dateFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        formatter.timeStyle = .none
//        return formatter
//    }()
//
//    func fetchUserData() {
//        if let user = Auth.auth().currentUser {
//            let db = Firestore.firestore()
//            let docRef = db.collection("users").document(user.uid)
//
//            docRef.getDocument { (document, error) in
//                if let document = document, document.exists {
//                    self.userProfile.name = document.get("name") as? String ?? ""
//                    self.userProfile.email = document.get("email") as? String ?? ""
//                    self.userProfile.location = document.get("location") as? String ?? ""
//                    self.userProfile.userName = document.get("userName") as? String ?? ""
//                    self.userProfile.userEmail = document.get("userEmail") as? String ?? ""
//                    self.userProfile.userLocation = document.get("userLocation") as? String ?? ""
//                    self.userProfile.userPhoneNumber = document.get("userPhoneNumber") as? String ?? ""
//                    self.userProfile.userBio = document.get("userBio") as? String ?? ""
//                    self.userProfile.userVerification = document.get("userVerification") as? String ?? ""
//                    self.userProfile.userCredential = document.get("userCredential") as? String ?? ""
//                    self.userProfile.userProfileImage = document.get("userProfileImage") as? String ?? ""
//                    self.userProfile.userWebsite = document.get("userWebsite") as? String ?? ""
//
//                    if let userBirthdayString = document.get("userBirthday") as? String,
//                       let userBirthday = dateFormatter.date(from: userBirthdayString) {
//                        self.userProfile.userBirthday = userBirthday
//                    } else {
//                        self.userProfile.userBirthday = Date()
//                    }
//
//                    if let userJoinedString = document.get("userJoined") as? String,
//                       let userJoined = dateFormatter.date(from: userJoinedString) {
//                        self.userProfile.userJoined = userJoined
//                    } else {
//                        self.userProfile.userJoined = Date()
//                    }
//                } else {
//                    print("Document does not exist.")
//                }
//                isContentLoaded = true
//            }
//        }
//    }
//
//    func loadImage() {
//        if let urlString = userProfile.userProfileImage, let url = URL(string: urlString) {
//            URLSession.shared.dataTask(with: url) { data, _, _ in
//                if let data = data, let uiImage = UIImage(data: data) {
//                    DispatchQueue.main.async {
//                        tempProfileImage = uiImage
//                        hasProfileImageLoaded = true
//                    }
//                } else {
//                    DispatchQueue.main.async {
//                        hasProfileImageLoaded = true
//                    }
//                }
//            }.resume()
//        } else {
//            hasProfileImageLoaded = true
//        }
//    }
//
//    var body: some View {
//        Group {
//            if isContentLoaded {
//                NavigationView {
//                    GeometryReader { geometry in
//                        ScrollView {
//                            VStack(alignment: .center, spacing: 20) {
//                                if let tempImage = tempProfileImage {
//                                    Image(uiImage: tempImage)
//                                        .resizable()
//                                        .scaledToFill()
//                                        .frame(width: 150, height: 150)
//                                        .clipShape(Circle())
//                                } else {
//                                    if let urlString = userProfile.userProfileImage, !urlString.isEmpty, let url = URL(string: urlString) {
//                                        AsyncImage(url: url) { image in
//                                            image.resizable()
//                                        } placeholder: {
//                                            if hasProfileImageLoaded {
//                                                ZStack {
//                                                    Circle()
//                                                        .fill(Color.white)
//                                                        .frame(width: 150, height: 150)
//
//                                                    ProgressView()
//                                                }
//                                            }
//                                        }
//                                        .scaledToFill()
//                                        .frame(width: 150, height: 150)
//                                        .clipShape(Circle())
//                                        .task {
//                                            hasProfileImageLoaded = true
//                                        }
//                                    } else if hasProfileImageLoaded {
//                                        Image(systemName: "person.crop.circle.fill")
//                                            .resizable()
//                                            .scaledToFit()
//                                            .frame(width: 150, height: 150)
//                                            .foregroundColor(.gray)
//                                    } else {
//                                        ZStack {
//                                            Circle()
//                                                .fill(Color.white)
//                                                .frame(width: 150, height: 150)
//
//                                            ProgressView()
//                                        }
//                                    }
//                                }
//                                Text(userProfile.userName)
//                                    .font(.title)
//                                    .fontWeight(.bold)
//
//                                Text(userProfile.userBio)
//                                    .font(.callout)
//                                    .foregroundColor(.gray)
//
//                                Button(action: {
//                                    showEditProfile.toggle()
//                                }) {
//                                    Text("Edit Profile")
//                                        .frame(minWidth: 0, maxWidth: .infinity)
//                                        .padding()
//                                        .background(Color.blue)
//                                        .foregroundColor(.white)
//                                        .cornerRadius(10)
//                                }
//                                .padding(.horizontal, 20)
//                                .sheet(isPresented: $showEditProfile) {
//                                    EditProfileView(userProfile: userProfile, userPhoto: tempProfileImage, onProfilePhotoUpdated: { newImage in
//                                        tempProfileImage = newImage
//                                    })
//                                }
//
//                                Button(action: {
//                                    showSettings.toggle()
//                                }) {
//                                    Text("Settings")
//                                }
//                                .padding(.horizontal, 20)
//                                .sheet(isPresented: $showSettings) {
//                                    SettingsView(userProfile: userProfile)
//                                }
//
//                                Spacer()
//                            }
//                            .padding(.top, 50)
//                            .padding(.horizontal, geometry.size.width * 0.05) // Apply 5% padding of screen width
//                            .navigationBarTitle("Profile", displayMode: .large)
//                        }
//                    }
//                }
//            } else {
//                VStack {
//                    Spacer()
//                    ProgressView()
//                    Spacer()
//                }
//            }
//        }
//        .onAppear {
//            fetchUserData()
//            loadImage()
//        }
//    }
//}

//import SwiftUI
//import AuthenticationServices
//import Firebase
//import FirebaseAppCheck
//import FirebaseAuth
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//        .environmentObject(AppData())
//    }
//}
//
//class AppDelegate: NSObject, UIApplicationDelegate {
//    func application(_ application: UIApplication,
//                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//        FirebaseApp.configure()
//
//        return true
//    }
//}
//
//class AuthStateDelegate: ObservableObject {
//    @Published var isAuthenticated = false
//
//    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
//
//    init() {
//        authStateListenerHandle = Auth.auth().addStateDidChangeListener { auth, user in
//            if user != nil {
//                self.isAuthenticated = true
//            } else {
//                self.isAuthenticated = false
//            }
//        }
//    }
//
//    func removeAuthStateListener() {
//        if let handle = authStateListenerHandle {
//            Auth.auth().removeStateDidChangeListener(handle)
//        }
//    }
//}
//
//@main
//struct QHHTBQHApp: App {
//    // register app delegate for Firebase setup
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
//    @StateObject private var authStateDelegate = AuthStateDelegate()
//
//    var body: some Scene {
//        WindowGroup {
//            NavigationView {
//                if authStateDelegate.isAuthenticated {
//                    ContentView()
//                } else {
//                    LoginPage()
//                }
//            }.environmentObject(authStateDelegate)
//        }
//    }
//}
//
//struct ContentView: View {
//    @EnvironmentObject var authStateDelegate: AuthStateDelegate
//
//    // Define the appData @StateObject
//    @StateObject var appData = AppData()
//
//    // Define the selectedTab @State
//    @State private var selectedTab = 0
//
//    // Define the ContentView body
//    var body: some View {
//
//        // Define the TabView
//        TabView(selection: $selectedTab) {
//
//            // Display the DirectoryView as the second tab
//            DirectoryView()
//                .navigationBarTitle("Directory", displayMode: .automatic)
//                .tabItem {
//                    Image(systemName: "magnifyingglass")
//                    Text("Directory")
//                }
//                .tag(0)
//                .environmentObject(appData)
//
//            // Display the ForumView as the third tab
//            ForumView()
//                .navigationBarTitle("Forum", displayMode: .automatic)
//                .tabItem {
//                    Image(systemName: "bubble.left.and.bubble.right")
//                    Text("Forum")
//                }
//                .tag(1)
//                .environmentObject(appData)
//
//            // Display the ProfileView as the fifth tab
//            ProfileView()
//                .navigationBarTitle("Me", displayMode: .automatic)
//                .tabItem {
//                    Image(systemName: "person.crop.circle")
//                    Text("Me")
//                }
//                .tag(2)
//                .environmentObject(appData)
//        }
//        .environmentObject(appData)
//    }
//}
//
//struct LoginPage: View {
//    @EnvironmentObject var authStateDelegate: AuthStateDelegate
//
//    var body: some View {
//        VStack {
//            Text("QHHT-BQH")
//                .font(.largeTitle)
//                .fontWeight(.bold)
//                .padding()
//
//            Text("Welcome!")
//                .font(.title)
//                .fontWeight(.medium)
//
//            SignInWithAppleButtonView { request in
//                request.requestedScopes = [.fullName, .email]
//            } onCompletion: { result in
//                switch result {
//                case .success(let authorization):
//                    guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
//                    let credential = OAuthProvider.credential(withProviderID: "apple.com",
//                                                              idToken: String(data: appleIDCredential.identityToken!, encoding: .utf8)!,
//                                                              rawNonce: nil)
//
//                    Auth.auth().signIn(with: credential) { authResult, error in
//                        if let error = error {
//                            print("Error signing in with Apple: \(error.localizedDescription)")
//                            return
//                        }
//
//                        if let user = authResult?.user {
//                            checkIfUserExists(uid: user.uid) { exists in
//                                if exists {
//                                    print("User document already exists.")
//                                } else {
//                                    let name = (appleIDCredential.fullName?.givenName ?? "") + " " + (appleIDCredential.fullName?.familyName ?? "")
//                                    let email = appleIDCredential.email ?? ""
//                                    let location = ""
//                                    let userName = ""
//                                    let userEmail = ""
//                                    let userLocation = ""
//                                    let userPhoneNumber = ""
//                                    let userBio = ""
//                                    let userVerification = ""
//                                    let userCredential = ""
//                                    let userProfileImage = ""
//                                    let userBirthday = Date()
//                                    let userWebsite = ""
//                                    let userJoined = Date()
//                                    createUserDocument(uid: user.uid, name: name, email: email, location: location, userName: userName, userEmail: userEmail, userLocation: userLocation, userPhoneNumber: userPhoneNumber, userBio: userBio, userVerification: userVerification, userCredential: userCredential, userProfileImage: userProfileImage, userBirthday: userBirthday, userWebsite: userWebsite, userJoined: userJoined)
//                                }
//                            }
//                        }
//                    }
//
//                case .failure(let error):
//                    print("Error with Sign in with Apple: \(error.localizedDescription)")
//                }
//            }
//
//            .frame(width: 280, height: 45)
//            .padding()
//        }
//    }
//}
//
//struct SignInWithAppleButtonView: UIViewRepresentable {
//    var onRequest: ((ASAuthorizationAppleIDRequest) -> Void)?
//    var onCompletion: ((Result<ASAuthorization, Error>) -> Void)?
//
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(onRequest: onRequest, onCompletion: onCompletion)
//    }
//
//    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
//        let button = ASAuthorizationAppleIDButton()
//        button.addTarget(context.coordinator, action: #selector(Coordinator.buttonTapped), for: .touchUpInside)
//        return button
//    }
//
//    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) { }
//
//    class Coordinator: NSObject, ASAuthorizationControllerDelegate {
//        var onRequest: ((ASAuthorizationAppleIDRequest) -> Void)?
//        var onCompletion: ((Result<ASAuthorization, Error>) -> Void)?
//
//        init(onRequest: ((ASAuthorizationAppleIDRequest) -> Void)?, onCompletion: ((Result<ASAuthorization, Error>) -> Void)?) {
//            self.onRequest = onRequest
//            self.onCompletion = onCompletion
//        }
//
//        @objc func buttonTapped() {
//            let provider = ASAuthorizationAppleIDProvider()
//            let request = provider.createRequest()
//            onRequest?(request)
//
//            let controller = ASAuthorizationController(authorizationRequests: [request])
//            controller.delegate = self
//            controller.performRequests()
//        }
//
//        func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
//            onCompletion?(.success(authorization))
//        }
//
//        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
//            onCompletion?(.failure(error))
//        }
//    }
//}
//
//func checkIfUserExists(uid: String, completion: @escaping (Bool) -> Void) {
//    let db = Firestore.firestore()
//    let docRef = db.collection("users").document(uid)
//
//    docRef.getDocument { (document, error) in
//        if let error = error {
//            print("Error checking user existence: \(error)")
//            completion(false)
//            return
//        }
//
//        if let document = document, document.exists {
//            completion(true)
//        } else {
//            completion(false)
//        }
//    }
//}
//
//func createUserDocument(uid: String, name: String, email: String, location: String, userName: String, userEmail: String, userLocation: String, userPhoneNumber: String, userBio: String, userVerification: String, userCredential: String, userProfileImage: String, userBirthday: Date, userWebsite: String, userJoined: Date) {
//    if let user = Auth.auth().currentUser {
//        let db = Firestore.firestore()
//        let userDocRef = db.collection("users").document(user.uid)
//
//        // Create or update the user document with the new fields
//        userDocRef.setData([
//            "name": name,
//            "email": email,
//            "location": location,
//            "userName": userName,
//            "userEmail": userEmail,
//            "userLocation": userLocation,
//            "userPhoneNumber": userPhoneNumber,
//            "userBio": userBio,
//            "userVerification": userVerification,
//            "userCredential": userCredential,
//            "userProfileImage": userProfileImage,
//            "userBirthday": userBirthday,
//            "userWebsite": userWebsite,
//            "userJoined": userJoined
//        ]) { error in
//            if let error = error {
//                print("Error creating or updating user document: \(error)")
//            } else {
//                print("User document successfully created or updated!")
//            }
//        }
//    }
//}
