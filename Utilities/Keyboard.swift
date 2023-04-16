import Foundation
import SwiftUI
import Combine

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct AdaptsToKeyboard: ViewModifier {
    @State private var currentHeight: CGFloat = 0

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .padding(.bottom, self.currentHeight)
                .onAppear(perform: {
                    self.setupKeyboardObservers(geometry: geometry)
                })
        }
    }

    private func setupKeyboardObservers(geometry: GeometryProxy) {
        let keyboardWillShowPublisher = NotificationCenter.Publisher(center: NotificationCenter.default, name: UIResponder.keyboardWillShowNotification)
        let keyboardWillChangeFramePublisher = NotificationCenter.Publisher(center: NotificationCenter.default, name: UIResponder.keyboardWillChangeFrameNotification)
        let mergedPublisher = keyboardWillShowPublisher.merge(with: keyboardWillChangeFramePublisher)

        mergedPublisher
            .compactMap { notification in
                withAnimation(.easeOut(duration: 0.16)) {
                    notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                }
            }
            .map { rect in
                rect.height - geometry.safeAreaInsets.bottom
            }
            .sink { newHeight in
                self.currentHeight = newHeight
            }
            .store(in: &cancellables)

        NotificationCenter.Publisher(center: NotificationCenter.default, name: UIResponder.keyboardWillHideNotification)
            .compactMap { _ in CGFloat.zero }
            .sink { newHeight in
                self.currentHeight = newHeight
            }
            .store(in: &cancellables)
    }

    @State private var cancellables = Set<AnyCancellable>()
}

extension View {
    func adaptsToKeyboard() -> some View {
        return modifier(AdaptsToKeyboard())
    }
}
