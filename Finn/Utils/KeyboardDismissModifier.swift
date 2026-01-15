import SwiftUI

extension View {
    func hideKeyboardOnTap() -> some View {
        modifier(KeyboardDismissModifier())
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}

struct KeyboardDismissModifier: ViewModifier {
    @State private var keyboardShown = false
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if keyboardShown {
                Color.black.opacity(0.01)
                    .ignoresSafeArea()
                    .onTapGesture {
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder),
                            to: nil, from: nil, for: nil
                        )
                    }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            keyboardShown = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            keyboardShown = false
        }
    }
}
