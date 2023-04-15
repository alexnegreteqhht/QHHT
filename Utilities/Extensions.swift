//
//  Extensions.swift
//  QHHT-BQH
//
//  Created by Alex Negrete on 4/15/23.
//

import Foundation
import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

//struct KeyboardAdaptive: ViewModifier {
//    @State private var keyboardHeight: CGFloat = 0
//
//    func body(content: Content) -> some View {
//        content
//            .padding(.bottom, keyboardHeight)
//            .animation(.easeOut(duration: 0.16), value: keyboardHeight)
//            .onAppear(perform: subscribeToKeyboardEvents)
//    }
//
//    private func subscribeToKeyboardEvents() {
//        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (notification) in
//            keyboardHeight = notification.keyboardHeight
//        }
//
//        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
//            keyboardHeight = 0
//        }
//    }
//}
//
//extension Notification {
//    var keyboardHeight: CGFloat {
//        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
//    }
//}
//
//extension View {
//    func keyboardAdaptive() -> ModifiedContent<Self, KeyboardAdaptive> {
//        return modifier(KeyboardAdaptive())
//    }
//}
