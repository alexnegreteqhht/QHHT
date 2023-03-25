import SwiftUI

struct RemoteImage: View {
    private let url: URL?
    private let placeholder: Image
    
    @State private var image: UIImage?
    
    init(url: URL?, placeholder: Image = Image(systemName: "photo")) {
        self.url = url
        self.placeholder = placeholder
    }
    
    var body: some View {
        if let image = image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.horizontal, 20)
        } else {
            placeholder
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.horizontal, 20)
                .onAppear {
                    loadImage()
                }
        }
    }
    
    private func loadImage() {
        guard let url = url else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.async {
                image = UIImage(data: data)
            }
        }.resume()
    }
}
