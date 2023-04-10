import SwiftUI
import Firebase
import FirebaseFirestore
import Combine
import FirebaseAppCheck

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
        .environmentObject(AppData())
    }
}

// View for the About tab
struct ProfileView: View {
    // Get the instance of AppData from the environment
    @EnvironmentObject var appData: AppData
    @ObservedObject var userProfile = UserProfile()
    @State private var showEditProfile = false
    @State private var showSettings = false
    @State private var userPhoto: UIImage? = nil
    
    func loadImageFromURL(urlString: String, completion: @escaping (UIImage?) -> Void) {
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        completion(image)
                    }
                } else {
                    completion(nil)
                }
            }.resume()
        } else {
            completion(nil)
        }
    }
    
    // Fetch user data from Firebase
    func fetchUserData() {
        if let user = Auth.auth().currentUser {
            
            let db = Firestore.firestore()
            let docRef = db.collection("users").document(user.uid)
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    self.userProfile.name = document.get("name") as? String ?? ""
                    self.userProfile.email = document.get("email") as? String ?? ""
                    self.userProfile.location = document.get("location") as? String ?? ""
                    self.userProfile.userName = document.get("userName") as? String ?? ""
                    self.userProfile.userEmail = document.get("userEmail") as? String ?? ""
                    self.userProfile.userLocation = document.get("userLocation") as? String ?? ""
                    self.userProfile.userPhoneNumber = document.get("userPhoneNumber") as? String ?? ""
                    self.userProfile.userBio = document.get("userBio") as? String ?? ""
                    self.userProfile.userVerification = document.get("userVerification") as? String ?? ""
                    self.userProfile.userCredential = document.get("userCredential") as? String ?? ""
                    self.userProfile.userProfileImage = document.get("userProfileImage") as? String ?? ""
                    self.userProfile.userWebsite = document.get("userWebsite") as? String ?? ""

                    if let userBirthdayString = document.get("userBirthday") as? String,
                       let userBirthday = dateFormatter.date(from: userBirthdayString) {
                        self.userProfile.userBirthday = userBirthday
                    } else {
                        self.userProfile.userBirthday = Date()
                    }
                    
                    if let userJoinedString = document.get("userJoined") as? String,
                       let userJoined = dateFormatter.date(from: userJoinedString) {
                        self.userProfile.userJoined = userJoined
                    } else {
                        self.userProfile.userJoined = Date()
                    }
                    
                    loadImageFromURL(urlString: self.userProfile.userProfileImage ?? "") { image in
                        userPhoto = image
                    }
                    
                } else {
                    print("Document does not exist.")
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .center, spacing: 20) {
                        if userProfile.userProfileImage != "" {
                            Image(uiImage: userPhoto ?? UIImage())
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .foregroundColor(.gray)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .foregroundColor(.gray)
                        }
                        
                        // User name
                        Text(userProfile.userName)
                        .font(.title)
                        .fontWeight(.bold)
                        
                        // Bio
//                            Text("Hi everyone! My name is Alex and I created this app. I'm a fan of Delores Cannon's work. I started practicing QHHT & BQH in 2023. I'm excited to meet you all.")
                        Text(userProfile.userBio)
                        .font(.callout)
                        .foregroundColor(.gray)
                        
                        // Edit profile button
                        Button(action: {
                            showEditProfile.toggle()
                        }) {
                            Text("Edit Profile")
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 20)
                        .sheet(isPresented: $showEditProfile) {
                            EditProfileView(userProfile: userProfile)
                        }
                        
                        // Edit profile button
                        Button(action: {
                            showSettings.toggle()
                        }) {
                            Text("Settings")
                        }
                        .padding(.horizontal, 20)
                        .sheet(isPresented: $showSettings) {
                            SettingsView(userProfile: userProfile)
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 50)
                                    .padding(.horizontal, geometry.size.width * 0.05) // Apply 5% padding of screen width
                    .navigationBarTitle("Profile", displayMode: .large)
                }
            }
        }
        
        // Fetch user data when the view appears
        .onAppear(perform: fetchUserData)
    }
}
