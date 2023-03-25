import SwiftUI

struct TestimonialsView_Previews: PreviewProvider {
    static var previews: some View {
        TestimonialsView()
        .environmentObject(AppData())
    }
}

// View for the Testimonials tab
struct TestimonialsView: View {
    // Get the instance of AppData from the environment
    @EnvironmentObject var appData: AppData
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(appData.testimonials) { testimonial in
                        VStack(alignment: .leading, spacing: 8) { // Decreased spacing to match other screens
                            Text(testimonial.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 20)
                            Text(testimonial.text)
                                .font(.body)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 20)
                        }
                    }
                        .padding(.vertical, 8) // Added vertical padding to match other screens
                }
            }
            .navigationBarTitle("Testimonials")
        }
    }
}
