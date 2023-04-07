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
    
    // Fetch user data from Firebase
    func fetchUserData() {
        if let user = Auth.auth().currentUser {
            
            let db = Firestore.firestore()
            let docRef = db.collection("users").document(user.uid)
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    self.userProfile.name = document.get("fullName") as? String ?? "No Name"
                    self.userProfile.email = document.get("emailAddress") as? String ?? "No Email"
                    self.userProfile.location = document.get("location") as? String ?? "No Location"
                    self.userProfile.userName = document.get("userName") as? String ?? "No User Name"
                    self.userProfile.userEmail = document.get("userName") as? String ?? "No User Email"
                    self.userProfile.userLocation = document.get("userName") as? String ?? "No User Location"
                    self.userProfile.userPhoneNumber = document.get("phoneNumber") as? String ?? "No User Phone Number"
                    self.userProfile.userBio = document.get("bio") as? String ?? "No User Bio"
                    self.userProfile.userType = document.get("userType") as? String ?? "No User Type"
                    self.userProfile.userCredentials = document.get("credentials") as? String ?? "No User Credentials"
                    self.userProfile.userPhotoURL = document.get("userPhotoURL") as? String ?? "No Photo URL"
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
                        // Profile picture
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .foregroundColor(.gray)
                        
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
                        
                        // Log out button
                        Button(action: {
                            // Log out the user and set the isAuthenticated variable to false
                            try? Auth.auth().signOut()
                        }, label: {
                            Text("Log Out")
                        })
                        
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
