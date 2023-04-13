import SwiftUI

struct ForumView_Previews: PreviewProvider {
    static var previews: some View {
        ForumView()
        .environmentObject(AppData())
    }
}

// View for the About tab
struct ForumView: View {
    // Get the instance of AppData from the environment
    @EnvironmentObject var appData: AppData
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                // Placeholder text
                Text("Get to know the community")
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarTitle("Forum")
        }
    }
}
