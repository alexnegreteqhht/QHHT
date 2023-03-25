import SwiftUI

struct PractitionerView_Previews: PreviewProvider {
    static var previews: some View {
        PractitionerView()
        .environmentObject(AppData())
    }
}

// View for the Practitioner tab
struct PractitionerView: View {
    // Get the instance of AppData from the environment
    @EnvironmentObject var appData: AppData
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Placeholder text
                    Text("Your name, credentials, experience, and a personal message go here.")
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                }
            }
            .navigationBarTitle("Practitioner")
        }
    }
}
