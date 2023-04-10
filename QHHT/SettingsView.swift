import SwiftUI
import Firebase

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(userProfile: UserProfile())
        .environmentObject(AppData())
    }
}

struct SettingsView: View {
    @ObservedObject var userProfile: UserProfile
    @Environment(\.presentationMode) var presentationMode
    @State private var showAlert: Bool = false
    @State private var errorMessage: String = ""
    
    func saveProfile() {
        // Save updated profile data to Firestore
        // Validate and process the data before saving
        if let user = Auth.auth().currentUser {
            let db = Firestore.firestore()
            let userRef = db.collection("users").document(user.uid)
            
            userRef.updateData([
                "userEmail": userProfile.userEmail,
                "userPhoneNumber": userProfile.userPhoneNumber
            ]) { error in
                if let error = error {
                    errorMessage = "Error updating account: \(error.localizedDescription)"
                    showAlert.toggle()
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            let joinedDateFormatter: DateFormatter = {
                let formatter = DateFormatter()
                formatter.dateStyle = .long
                formatter.timeStyle = .none
                return formatter
            }()
            Form {
                Section(header: Text("Account"), footer: Text("Joined: \(joinedDateFormatter.string(from: userProfile.userJoined))")) {
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

                // Log out button
                Button(action: {
                    // Log out the user and set the isAuthenticated variable to false
                    try? Auth.auth().signOut()
                }, label: {
                    Text("Log Out")
                })

                .navigationBarTitle("Settings", displayMode: .inline)
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
}
