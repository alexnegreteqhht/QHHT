import SwiftUI

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
        .environmentObject(AppData())
    }
}

// View for the About tab
struct HomeView: View {
    // Get the instance of AppData from the environment
    @EnvironmentObject var appData: AppData
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                // Placeholder text
                Text("New content daily")
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarTitle("Home")
        }
    }
}
