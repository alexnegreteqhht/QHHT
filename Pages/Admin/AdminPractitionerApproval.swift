import Foundation
import SwiftUI

struct AdminPractitionerApprovalView_Previews: PreviewProvider {
    static var previews: some View {
        AdminPractitionerApprovalView()
    }
}

struct AdminPractitionerApprovalView: View {
    @State private var unapprovedPractitioners: [UserProfile] = []

    var body: some View {
        VStack {
            if unapprovedPractitioners.isEmpty {
                Text("No practitioners to display")
                    .font(.title)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List(unapprovedPractitioners, id: \.id) { practitioner in
                    NavigationLink(destination: UserProfileView(user: practitioner, showApproveButton: true)) {
                        HStack {
                            FirebaseImage(url: practitioner.profileImageURL ?? "")
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())

                            VStack(alignment: .leading) {
                                Text(practitioner.name)
                                    .font(.headline)
                            }
                            Spacer()
                            AdminHelper.approveButton(for: practitioner)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
        }
        .navigationTitle("Approve Practitioners")
        .onAppear {
            FirebaseHelper.fetchUnapprovedPractitioners { fetchedPractitioners in
                unapprovedPractitioners = fetchedPractitioners
                print("Fetched practitioners count: \(unapprovedPractitioners.count)")
            }
        }
    }
}
