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

//import SwiftUI
//import WebKit
//
//struct ServicesView_Previews: PreviewProvider {
//    static var previews: some View {
//        ServicesView()
//        .environmentObject(AppData())
//    }
//}
//
//struct WebView: UIViewRepresentable {
//    let url: URL
//
//    func makeUIView(context: Context) -> WKWebView {
//        let webView = WKWebView(frame: .zero, configuration: webViewConfiguration())
//        webView.load(URLRequest(url: url))
//        return webView
//    }
//
//    func updateUIView(_ uiView: WKWebView, context: Context) {
//        // Empty for now
//    }
//
//    private func webViewConfiguration() -> WKWebViewConfiguration {
//        let configuration = WKWebViewConfiguration()
//        configuration.allowsInlineMediaPlayback = true
//        configuration.mediaTypesRequiringUserActionForPlayback = []
//        return configuration
//    }
//}
//
//// View for the Services tab
//struct ServicesView: View {
//    // Get the instance of AppData from the environment
//    @EnvironmentObject var appData: AppData
//    @State private var showBookingWebView = false
//    let bookingURL = "https://www.alexnegrete.com"
//
//    var body: some View {
//        NavigationStack {
//            ScrollView {
//                VStack(alignment: .leading, spacing: 16) {
//                    // Placeholder text
//                    Text("Your name, credentials, experience, and a personal message go here.")
//                        .font(.body)
//                        .foregroundColor(.primary)
//                        .padding(.horizontal, 20)
//
//                    ForEach(appData.services) { service in
//                        VStack(alignment: .leading, spacing: 8) {
//                            Text(service.title)
//                                .font(.headline)
//                                .foregroundColor(Color.primary)
//                                .padding(.horizontal, 20)
//
//                            Text(String(format: "$%.2f", service.price))
//                                .font(.subheadline)
//                                .foregroundColor(Color.primary)
//                                .padding(.horizontal, 20)
//
//                            Text(service.description)
//                                .font(.body)
//                                .foregroundColor(Color.primary)
//                                .padding(.horizontal, 20)
//
//                        }
//                        .padding(.vertical, 8)
//
//                    }
//                    // Add the booking button
//                    Button(action: {
//                        showBookingWebView.toggle()
//                    }) {
//                        Text("Book a Session")
//                            .font(.headline)
//                            .foregroundColor(.white)
//                            .padding()
//                            .background(Color.blue)
//                            .cornerRadius(10)
//                    }
//                    .padding()
//                    .sheet(isPresented: $showBookingWebView) {
//                        WebView(url: URL(string: bookingURL)!)
//                            .edgesIgnoringSafeArea(.all)
//                    }
//                }
//                .navigationBarTitle("Services")
//            }
//        }
//    }
//}
