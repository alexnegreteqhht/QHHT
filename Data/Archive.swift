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


//                Section(header: Text("Profile"), footer: Text("We use your birthday to personalize your experience and offer discounts. Your birth year will not be shown on your profile.")) {
//                    TextField("Name", text: $userName)
//                        .onChange(of: userProfile.userName) { newValue in
//                            userProfile.userName = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
//                        }
//
//                    TextEditor(text: $userBio)
//                        .frame(height: 100)
//                        .onChange(of: userBio) { newValue in
//                            if newValue.count > 160 {
//                                userBio = String(newValue.prefix(160))
//                            }
//                        }
//                        .onChange(of: userBio) { newValue in
//                            userBio = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
//                        }
//                        .overlay(
//                            Group {
//                                if userBio.isEmpty {
//                                    Text("Bio")
//                                        .foregroundColor(Color(.placeholderText))
//                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
//                                        .padding(.top, 8)
//                                        .padding(.leading, 4)
//                                }
//                            }
//                        )
//
//                    TextField("Location", text: $userLocation)
//                        .onChange(of: userProfile.userLocation) { newValue in
//                            userProfile.userLocation = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
//                        }
//
//                    TextField("Website", text: $userWebsite)
//                        .autocapitalization(.none)
//                        .onChange(of: userProfile.userWebsite) { newValue in
//                            userProfile.userWebsite = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
//                        }
    
//                    Button(action: {
//                        showDatePicker.toggle()
//                    }) {
//                        HStack {
//                            Text("Birthday")
//                                .foregroundColor(Color.secondary)
//                            Spacer()
//                            if isBirthdaySet {
//                                Text("\(userProfile.userBirthday, formatter: FirebaseHelper().dateFormatter)")
//                                    .foregroundColor(Color(.placeholderText))
//                            } else {
//                                Text("Set Date")
//                                    .foregroundColor(.blue)
//                            }
//                        }
//                    }
//                    .onAppear {
//                        isBirthdaySet = !Calendar.current.isDateInToday(userProfile.userBirthday)
//                    }
//                    .onChange(of: userProfile.userBirthday) { _ in
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
//                }

//                Section(header: Text("Birthday"), footer: Text("We use this to improve your experience and give you discounts from practitioners. Your birth year will not be shown.")) {
//                    Button(action: {
//                        showDatePicker.toggle()
//                    }) {
//                        if isBirthdaySet {
//                            Text("\(userProfile.userBirthday, formatter: FirebaseHelper().dateFormatter)")
//                                .foregroundColor(Color(.placeholderText))
//                        } else {
//                            Text("Add Birthday")
//                        }
//                    }
//
//                    .onChange(of: userProfile.userBirthday) { _ in
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
//                }
//
//                Section(header: Text("Verification"), footer: Text("We ensure all practitioners on our platform are verified. Become a verified practitioner by uploading an image of your certification.")) {
//                    Button(action: { showCredentialImagePicker.toggle() }) {
//                            if let credentialImage = credentialImage {
//                                Image(uiImage: credentialImage)
//                                    .resizable()
//                                    .scaledToFill()
//                                    .frame(width: 150, height: 150)
//                                    .clipped()
//                                    .frame(maxWidth: .infinity, alignment: .center)
//                            } else if !isLoadingCredentialImage {
//                                Image(systemName: "doc.badge.plus")
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(width: 150, height: 150)
//                                    .foregroundColor(.gray)
//                                    .frame(maxWidth: .infinity, alignment: .center)
//                            }
//
//                            if isLoadingCredentialImage {
//                                ProgressView()
//                                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
//                                    .scaleEffect(1.0)
//                                    .frame(width: 150, height: 150)
//                            }
//                    }
//                    Button(action: {
//                        showCredentialImagePicker.toggle()
//                    }) {
//                        Text("Upload Credential")
//                            .frame(maxWidth: .infinity, alignment: .center)
//                            .sheet(isPresented: $showCredentialImagePicker) {
//                                ImagePicker(selectedImage: $credentialImage, imageData: $credentialImageData)
//                            }
//                    }
//                }
//            }
//
//func updateUserProfile(userRef: DocumentReference) {
//    userRef.updateData([
//        "name": userProfile.name,
//        "email": userProfile.email,
//        "location": userProfile.location,
//        "userName": userProfile.userName,
//        "userEmail": userProfile.userEmail,
//        "userLocation": userProfile.userLocation,
//        "userPhoneNumber": userProfile.userPhoneNumber,
//        "userBio": userProfile.userBio,
//        "userVerification": userProfile.userVerification,
//        "userCredential": userProfile.userCredential ?? "",
//        "userProfileImage": userProfile.userProfileImage ?? "",
//        "userWebsite": userProfile.userWebsite,
//        "userBirthday": GlobalDefaults.dateFormatter.string(from: userProfile.userBirthday),
//        "userJoined": GlobalDefaults.dateFormatter.string(from: userProfile.userJoined)
//    ]) { error in
//        if let error = error {
//            errorMessage = "Error updating profile: \(error.localizedDescription)"
//            showAlert.toggle()
//        } else {
//            if let credentialURL = userProfile.userCredential {
//                FirebaseHelper.loadImageFromURL(urlString: credentialURL) { (image: UIImage?) in
//                    if let image = image {
//                        credentialImage = image
//                    }
//                }
//            }
//            if let profileImageURL = userProfile.userProfileImage {
//                userProfile.profileImageURL = profileImageURL
//            }
//            DispatchQueue.main.async {
//                onProfileUpdated?() // Call the closure here
//                self.presentationMode.wrappedValue.dismiss()
//                isSavingProfile = false
//            }
//        }
//    }
//}

//        isSavingProfile = true
//        if let user = Auth.auth().currentUser {
//            let db = Firestore.firestore()
//            let storage = Storage.storage()
//            let userRef = db.collection("users").document(user.uid)
//
//            let dispatchGroup = DispatchGroup()
//
//            userRef.updateData([
//                "userEmail": userProfile.userEmail,
//                "userPhoneNumber": userProfile.userPhoneNumber,
//                "userBirthday": userProfile.userBirthday
//            ]) { error in
//                if let error = error {
//                    errorMessage = "Error updating account: \(error.localizedDescription)"
//                    showAlert.toggle()
//                } else {
//                    presentationMode.wrappedValue.dismiss()
//                }
//            }
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
//            dispatchGroup.notify(queue: .main) {
//                userRef.updateData([
//                    "userCredential": userProfile.userCredential ?? ""
//                ]) { error in
//                    if let error = error {
//                        errorMessage = "Error updating user credential: \(error.localizedDescription)"
//                        showAlert.toggle()
//                    }
//                }
//                isSavingProfile = false
//            }
//        }
//    static func loadProfileImage(userProfile: UserProfile, isLoadingProfileImage: Bool, completion: @escaping (UIImage?) -> Void) {
//
//        if let userProfileImage = userProfile.userProfileImage, let url = URL(string: userProfileImage) {
//            let storageRef = Storage.storage().reference(forURL: url.absoluteString)
//            storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
//                if let error = error {
//                    print("Error loading profile image: \(error.localizedDescription)")
//                } else if let data = data {
//                    completion(UIImage(data: data))
//                }
//            }
//        }
//    }
    
//    static func loadImages(userProfile: UserProfile, isLoadingUserPhoto) {
//        isLoadingUserPhoto = true
//
//        if let profileImageURL = userProfile.userProfileImage {
//            FirebaseHelper.loadImageFromURL(urlString: profileImageURL) { image in
//                if let image = image {
//                    userPhoto = image
//                }
//                isLoadingUserPhoto = false
//            }
//        } else {
//            isLoadingUserPhoto = false
//        }
//    }

//static func loadCredentialImage(userProfile: UserProfile, isLoadingCredentialImage: Bool, completion: @escaping (UIImage?) -> Void) {
//    if let userCredential = userProfile.userCredential, let url = URL(string: userCredential) {
//        let storageRef = Storage.storage().reference(forURL: url.absoluteString)
//        storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
//            if let error = error {
//                print("Error loading credential image: \(error.localizedDescription)")
//            } else if let data = data {
//                completion(UIImage(data: data))
//            }
//        }
//    }
//}
//
//
//            isLoadingCredentialImage = true
//            FirebaseHelper.loadCredentialImage(userProfile: userProfile, isLoadingCredentialImage: isLoadingCredentialImage) { (image: UIImage?) in
//                if let image = image {
//                    credentialImage = image
//                }
//                isLoadingCredentialImage = false
//            }
//
//
//            FirebaseHelper.loadImage(urlString: userProfile.userProfileImage) { uiImage in
//                tempProfileImage = uiImage
//            }
//func loadImage(urlString: String?, completion: @escaping (UIImage?) -> Void) {
//            if let urlString = urlString, let url = URL(string: urlString) {
//                URLSession.shared.dataTask(with: url) { data, _, _ in
//                    if let data = data, let uiImage = UIImage(data: data) {
//                        DispatchQueue.main.async {
//                            completion(uiImage)
//                        }
//                    } else {
//                        DispatchQueue.main.async {
//                            completion(nil)
//                        }
//                    }
//                }.resume()
//            } else {
//                completion(nil)
//            }
//        }
//
//FirebaseHelper.loadImage(urlString: userProfileImageURL) { uiImage in
//    tempProfileImage = uiImage
//}

//import SwiftUI
//import Photos
//import Firebase
//import FirebaseAuth
//import FirebaseStorage
//import FirebaseFirestore
//
//struct SettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileView(userProfile: UserProfile(name: "", headline: "", profileImageURL: ""))
//
//    }
//}
//
//struct SettingsView: View {
//    @ObservedObject var userProfile: UserProfile
//    @Environment(\.presentationMode) private var presentationMode
//    @State private var showAlert: Bool = false
//    @State private var errorMessage: String = ""
//    @State private var showDatePicker = false
//    @State private var isBirthdaySet = false
//    @State private var credentialImage: UIImage?
//    @State private var credentialImageData: Data?
//    @State private var showCredentialImagePicker = false
//    @State private var isLoadingCredentialImage: Bool = false
//    @State private var isSavingProfile: Bool = false
//
//    func loadUserBirthday() {
//        if let user = Auth.auth().currentUser {
//            let db = Firestore.firestore()
//            let userRef = db.collection("users").document(user.uid)
//
//            userRef.getDocument { document, error in
//                if let document = document, document.exists {
//                    if let birthday = document.data()?["birthday"] as? Timestamp {
//                        DispatchQueue.main.async { // Add this line
//                            userProfile.birthday = birthday.dateValue()
//                            isBirthdaySet = !Calendar.current.isDateInToday(userProfile.birthday)
//                        }
//                    } else {
//                        isBirthdaySet = false
//                    }
//                } else {
//                    print("Error fetching user's birthday: \(error?.localizedDescription ?? "Unknown error")")
//                }
//            }
//        }
//    }
//
//    func updateUserSettings(userRef: DocumentReference) {
//        userRef.updateData([
//            "email": userProfile.email,
//            "phone": userProfile.phone,
//            "birthday": userProfile.birthday
//        ]) { error in
//            if let error = error {
//                errorMessage = "Error updating account: \(error.localizedDescription)"
//                showAlert.toggle()
//            } else {
//                presentationMode.wrappedValue.dismiss()
//            }
//        }
//    }
//
//    func saveProfile() {
//        isSavingProfile = true
//        if let user = Auth.auth().currentUser {
//            let userRef = Firestore.firestore().collection("users").document(user.uid)
//            let dispatchGroup = DispatchGroup()
//
//            if let credentialImageData = credentialImageData {
//                dispatchGroup.enter()
//                FirebaseHelper.uploadImageToStorage(imageData: credentialImageData, imagePath: "credentialImages/\(user.uid).jpg") { result in
//                    switch result {
//                    case .success(let urlString):
//                        userProfile.credentialImageURL = urlString
//                    case .failure(let error):
//                        errorMessage = "Error uploading credential image: \(error.localizedDescription)"
//                        showAlert.toggle()
//                    }
//                    dispatchGroup.leave()
//                }
//            }
//
//            dispatchGroup.notify(queue: .main) {
//                updateUserSettings(userRef: userRef)
//            }
//        }
//    }
//
//    var body: some View {
//        NavigationStack {
//            Form {
//                Section(header: Text("Birthday"), footer: Text("We use this to improve your experience and give you discounts.")) {
//                    if isBirthdaySet {
//                        Text("\(userProfile.userBirthday, formatter: GlobalDefaults.dateFormatter)")
//                            .foregroundColor(Color(.placeholderText))
//                    } else {
//                        Button(action: {
//                            showDatePicker.toggle()
//                        }) {
//                            Text("Add Birthday")
//                        }
//                        .onChange(of: userProfile.userBirthday) { _ in
//                            isBirthdaySet = !Calendar.current.isDateInToday(userProfile.userBirthday)
//                        }
//                        .sheet(isPresented: $showDatePicker) {
//                            VStack {
//                                Text("Select Your Birthday")
//                                    .font(.headline)
//                                DatePicker("", selection: $userProfile.userBirthday, displayedComponents: .date)
//                                    .datePickerStyle(WheelDatePickerStyle())
//                                    .labelsHidden()
//                                Button(action: {
//                                    isBirthdaySet = true
//                                    showDatePicker = false
//                                }) {
//                                    Text("Done")
//                                        .padding()
//                                        .background(Color.blue)
//                                        .foregroundColor(.white)
//                                        .cornerRadius(10)
//                                }
//                                .padding(.top)
//                            }
//                            .padding()
//                        }
//                    }
//                }
//
//                Section(header: Text("Security"), footer: Text("We use this to secure your account and send you important updates.")) {
//                TextField("Email", text: $userProfile.userEmail)
//                    .autocapitalization(.none)
//                    .onChange(of: userProfile.userEmail) { newValue in
//                        userProfile.userEmail = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
//                    }
//                TextField("Phone", text: $userProfile.userPhoneNumber)
//                    .onChange(of: userProfile.userPhoneNumber) { newValue in
//                        userProfile.userPhoneNumber = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
//                    }
//                }
//
//                Section(header: Text("Verification"), footer: Text("Become a verified practitioner by uploading an image of your certification.")) {
//                    Button(action: { showCredentialImagePicker.toggle() }) {
//                        ZStack {
//                            if let credentialImage = credentialImage {
//                                Image(uiImage: credentialImage)
//                                    .resizable()
//                                    .scaledToFill()
//                                    .frame(width: 150, height: 150)
//                                    .clipped()
//                            } else if !isLoadingCredentialImage {
//                                Image(systemName: "doc.badge.plus")
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(width: 150, height: 150)
//                                    .foregroundColor(.gray)
//                            }
//
//                            if isLoadingCredentialImage {
//                                ProgressView()
//                                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
//                                    .scaleEffect(1.0)
//                                    .frame(width: 150, height: 150)
//                            }
//                        }
//                        .frame(maxWidth: .infinity, alignment: .center)
//                    }
//                    Button(action: {
//                        showCredentialImagePicker.toggle()
//                    }) {
//                        Text("Upload Credential")
//                            .frame(maxWidth: .infinity, alignment: .center)
//                            .sheet(isPresented: $showCredentialImagePicker) {
//                                ImagePicker(selectedImage: $credentialImage, imageData: $credentialImageData)
//                            }
//                    }
//                }
//            }
//
//            .ignoresSafeArea(.keyboard)
//            .gesture(DragGesture().onChanged({ _ in
//                UIApplication.shared.endEditing()
//            }))
//
//                // Last Login
//
//                //                Text("Joined: \(userProfile.userJoined, formatter: FirebaseHelper().dateFormatter)")
//
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
//            .navigationBarTitle("Settings", displayMode: .inline)
//
//            .navigationBarItems(
//                leading:
//                    Button("Cancel") {
//                        presentationMode.wrappedValue.dismiss()
//                    },
//                trailing:
//                    Group {
//                        if isSavingProfile {
//                            ProgressView()
//                                .progressViewStyle(CircularProgressViewStyle(tint: .gray))
//                        } else {
//                            Button("Save") {
//                                saveProfile()
//                            }
//                        }
//                    }
//            )
//            .alert(isPresented: $showAlert) {
//                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
//
//            }
//
//
//            .onAppear {
//                isLoadingCredentialImage = true
//                if let credentialImageURL = userProfile.credentialImageURL {
//                    FirebaseHelper.loadImageFromURL(urlString: credentialImageURL) { image in
//                        if let image = image {
//                            credentialImage = image
//                        }
//                        isLoadingCredentialImage = false
//                    }
//                } else {
//                    isLoadingCredentialImage = false
//                }
//                loadUserBirthday()
//            }
//
//        }
//    }
//}
//private var headlineSection: some View {
//    Section(header: Text("Headline")) {
//        TextField("Introduce yourself to the community", text: $userProfile.headline).onChange(of: userProfile.headline) { newValue in
//            userProfile.headline = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
//        }
//    }
//}
//import SwiftUI
//import Photos
//import Firebase
//import FirebaseAuth
//import FirebaseStorage
//import FirebaseFirestore
//
//struct EditProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileView(userProfile: UserProfile(name: "", headline: "", profileImageURL: ""))
//            .environmentObject(UserProfileData.previewData())
//    }
//}
//
//struct EditProfileView: View {
//    @ObservedObject var userProfile: UserProfile
//    @Environment(\.presentationMode) private var presentationMode
//    @State var profileImage: UIImage? = nil
//    @State private var profileImageData: Data? = nil
//    @State private var showImagePicker: Bool = false
//    @State private var showAlert: Bool = false
//    @State private var errorMessage: String = ""
//    @State private var credentialImage: UIImage?
//    @State private var credentialImageData: Data?
//    @State private var showCredentialImagePicker = false
//    @State private var isLoadingCredentialImage: Bool = false
//    @State private var showDatePicker = false
//    @State private var isBirthdaySet = false
//    @State private var isLoadingUserPhoto: Bool = false
//    @State private var userName: String = ""
//    @State private var userBio: String = ""
//    @State private var userLocation: String = ""
//    @State private var userWebsite: String = ""
//    @State private var isSavingProfile: Bool = false
//    var onProfileUpdated: (() -> Void)?
//    var onProfileImageUpdated: ((UIImage) -> Bool)?
//
//    func updateUserProfile(userRef: DocumentReference) {
//        userRef.updateData([
//            "profileImageURL": userProfile.profileImageURL ?? "",
//            "name": userProfile.name,
//            "headline": userProfile.headline,
//            "location": userProfile.location,
//            "link": userProfile.link,
//        ]) { error in
//            if let error = error {
//                errorMessage = "Error updating profile: \(error.localizedDescription)"
//                showAlert.toggle()
//            } else {
//                if let profileImageURL = userProfile.profileImageURL {
//                    FirebaseHelper.loadImageFromURL(urlString: profileImageURL) { (image: UIImage?) in
//                        if let image = image {
//                            profileImage = image
//                        }
//                    }
//                }
//                if let profileImageURL = userProfile.profileImageURL {
//                    userProfile.profileImageURL = profileImageURL
//                }
//                DispatchQueue.main.async {
//                    onProfileUpdated?()
//                    self.presentationMode.wrappedValue.dismiss()
//                    isSavingProfile = false
//                }
//            }
//        }
//    }
//
//    func saveProfile() {
//        isSavingProfile = true
//        if let user = Auth.auth().currentUser {
//            let userRef = Firestore.firestore().collection("users").document(user.uid)
//            let dispatchGroup = DispatchGroup()
//
//            if let profileImageData = profileImageData {
//                dispatchGroup.enter()
//                FirebaseHelper.uploadImageToStorage(imageData: profileImageData, imagePath: "profileImages/\(user.uid).jpg") { result in
//                    switch result {
//                    case .success(let urlString):
//                        userProfile.profileImageURL = urlString
//                    case .failure(let error):
//                        errorMessage = "Error uploading profile image: \(error.localizedDescription)"
//                        showAlert.toggle()
//                    }
//                    dispatchGroup.leave()
//                }
//            }
//            dispatchGroup.notify(queue: .main) {
//                updateUserProfile(userRef: userRef)
//            }
//        }
//    }
//
//    var body: some View {
//        NavigationStack {
//            Form {
//                Section {
//                    if let profileImage = profileImage {
//                        Button(action: {
//                            showImagePicker.toggle()
//                        }) {
//                            Image(uiImage: profileImage)
//                                .resizable()
//                                .scaledToFill()
//                                .frame(width: 150, height: 150)
//                                .clipShape(Circle())
//                                .frame(maxWidth: .infinity, alignment: .center)
//                        }
//                    } else {
//                        Button(action: {
//                            showImagePicker.toggle()
//                        }) {
//                            ZStack {
//                                RoundedRectangle(cornerRadius: 75)
//                                    .foregroundColor(.clear)
//                                    .frame(width: 150, height: 150)
//
//                                if !isLoadingUserPhoto {
//                                    Image(systemName: "person.crop.circle.fill.badge.plus")
//                                        .resizable()
//                                        .scaledToFit()
//                                        .frame(width: 150, height: 150)
//                                        .foregroundColor(.gray)
//                                        .frame(maxWidth: .infinity, alignment: .center)
//                                } else {
//                                    ProgressView()
//                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                                }
//                            }
//                            .frame(maxWidth: .infinity, alignment: .center)
//                        }
//                    }
//
//                    Button(action: {
//                        showImagePicker.toggle()
//                    }) {
//
//                        if profileImage != nil {
//                            Text("Edit Photo")
//                                .frame(maxWidth: .infinity, alignment: .center)
//                                .sheet(isPresented: $showImagePicker) {
//                                    ImagePicker(selectedImage: $profileImage, imageData: $profileImageData)
//                                }
//                        } else {
//                            Text("Add Photo")
//                                .frame(maxWidth: .infinity, alignment: .center)
//                                .sheet(isPresented: $showImagePicker) {
//                                    ImagePicker(selectedImage: $profileImage, imageData: $profileImageData)
//                                }
//                        }
//                    }
//                }
//                .sheet(isPresented: $showImagePicker) {
//                    ImagePicker(selectedImage: $profileImage, imageData: $profileImageData)
//                }
//
//                Section(header: Text("Name")) {
//                    TextField("Your identity on the platform", text: $userName).onChange(of: userProfile.userName) { newValue in
//                        userProfile.userName = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
//                    }
//                }
//
//                Section(header: Text("Headline")) {
//                    TextField("Introduce yourself to the community", text: $userBio).onChange(of: userProfile.userBio) { newValue in
//                        userProfile.userBio = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
//                    }
//                }
//
//                Section(header: Text("Location")) {
//                    TextField("Find practitioners near you", text: $userLocation).onChange(of: userProfile.userLocation) { newValue in
//                        userProfile.userLocation = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
//                    }
//                }
//
//                Section(header: Text("Link")) {
//                    TextField("Primary website or social media", text: $userWebsite)
//                        .autocapitalization(.none)
//                        .onChange(of: userProfile.userWebsite) { newValue in
//                            userProfile.userWebsite = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
//                        }
//                }
//
//
//                .ignoresSafeArea(.keyboard)
//                .gesture(DragGesture().onChanged({ _ in
//                    UIApplication.shared.endEditing()
//                }))
//
//                .navigationBarItems(leading: Button("Cancel") {
//                    presentationMode.wrappedValue.dismiss()
//                }, trailing:
//                                        Group {
//                    if isSavingProfile {
//                        ProgressView()
//                            .progressViewStyle(CircularProgressViewStyle(tint: .gray))
//                    } else {
//                        Button("Save") {
//                            userProfile.userName = userName
//                            userProfile.userBio = userBio
//                            userProfile.userLocation = userLocation
//                            userProfile.userWebsite = userWebsite
//                            saveProfile()
//                        }
//                    }
//                })
//                .onAppear {
//                    isLoadingUserPhoto = true
//                    if let userProfileImageURL = userProfile.userProfileImageURL {
//                        FirebaseHelper.loadImageFromURL(urlString: userProfileImageURL) { image in
//                            if let image = image {
//                                profileImage = image
//                            }
//                            isLoadingUserPhoto = false
//                        }
//                    } else {
//                        isLoadingUserPhoto = false
//                    }
//
//                    userName = userProfile.userName
//                    userBio = userProfile.userBio
//                    userLocation = userProfile.userLocation
//                    userWebsite = userProfile.userWebsite
//                }
//            }
//        }
//    }
//}

