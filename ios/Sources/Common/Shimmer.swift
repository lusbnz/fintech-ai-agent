import SwiftUI

struct Shimmer: ViewModifier {
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [.clear, .white.opacity(0.4), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: isAnimating ? 300 : -300)
                .animation(
                    Animation.linear(duration: 1.5).repeatForever(autoreverses: false),
                    value: isAnimating
                )
            )
            .onAppear { isAnimating = true }
    }
}

extension View {
    func shimmering() -> some View {
        modifier(Shimmer())
    }
}
