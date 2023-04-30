import Foundation
import SwiftUI
import Combine

struct AdminPractitionerApprovalView_Previews: PreviewProvider {
    static var previews: some View {
        AdminPractitionerApprovalView()
    }
}

struct AdminPractitionerApprovalView: View {
    @State private var unapprovedPractitioners: [UserProfile] = []
    @State private var refresh = false

    var body: some View {
        VStack {
            if unapprovedPractitioners.isEmpty {
                Text("No practitioners to display")
                    .font(.title)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List(unapprovedPractitioners, id: \.id) { practitioner in
                    NavigationLink(destination: UserProfileView(user: practitioner, showApproveButton: true, refreshParent: $refresh)) {
                        HStack {
                            FirebaseImage(url: practitioner.profileImageURL ?? "")
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())

                            VStack(alignment: .leading) {
                                Text(practitioner.name)
                                    .font(.headline)
                            }
                            Spacer()
                            approveButton(for: practitioner)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
        }
        .navigationTitle("Approve Practitioners")
        .onAppear {
            fetchUnapprovedPractitioners()
        }
        .onChange(of: refresh) { value in
            if value {
                fetchUnapprovedPractitioners()
                // Reset the refresh trigger
                self.refresh = false
            }
        }
    }

    func fetchUnapprovedPractitioners() {
        FirebaseHelper.fetchUnapprovedPractitioners { fetchedPractitioners in
            unapprovedPractitioners = fetchedPractitioners
            print("Fetched practitioners count: \(unapprovedPractitioners.count)")
        }
    }
    
    func approveButton(for practitioner: UserProfile) -> some View {
        Button(action: {
            FirebaseHelper.approveUser(userProfile: practitioner) { result in
                switch result {
                case .success():
                    // Trigger a refresh in the parent view
                    self.refresh = true
                case .failure(let error):
                    print("Error approving user: \(error.localizedDescription)")
                }
            }
        }) {
            Text("Approve")
        }
        .buttonStyle(AdminHelper.ApproveButtonStyle())
    }
}
