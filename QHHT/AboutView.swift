import SwiftUI

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
        .environmentObject(AppData())
    }
}

// View for the About tab
struct AboutView: View {
    // Get the instance of AppData from the environment
    @EnvironmentObject var appData: AppData
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Placeholder text
                    Text("Quantum Healing Hypnosis Technique (QHHT) is a method developed by Dolores Cannon that uses hypnosis to facilitate past life regression and healing. Through QHHT, individuals can access their subconscious mind to uncover insights about their past lives, which can help them understand and resolve current life issues. QHHT also aims to promote healing and personal growth by connecting people to their higher self and inner wisdom.")
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                    
                    VStack(alignment: .leading, spacing: 8) {
                            Text("Resources")
                                .font(.title)
                                .bold()
                                .foregroundColor(.primary)
                                .padding(.horizontal, 20)
        
                            ForEach(appData.resources) { resource in
                                Link(resource.title, destination: URL(string: resource.url)!)
                                    .font(.body)
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 20)
                            }
                        }
        
                        VStack(alignment: .center, spacing: 16) {
                            RemoteImage(url: URL(string: "https://uploads-ssl.webflow.com/63c58f0e383b082fb394a3ea/63c5fe6a3f09c3c5d77b8a48_shutterstock_430472275.jpg"))
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationBarTitle("About")
        }
    }
}
