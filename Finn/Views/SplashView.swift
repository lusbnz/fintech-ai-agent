import SwiftUI

struct SplashView: View {
    @State private var logoScale: CGFloat = 0.6
    @State private var logoOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var offsetY: CGFloat = 20

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.white,
                    Color(hex: "F2F4F8")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                VStack(spacing: 10) {
                    Text("Finn")
                        .font(.system(size: 44, weight: .heavy, design: .rounded))
                        .foregroundColor(.black)
                        .opacity(logoOpacity)
                        .scaleEffect(logoScale)
                        .offset(y: offsetY)
                        .shadow(color: .black.opacity(0.08), radius: 10, y: 4)

                    Text("Financial Intelligence for You")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .opacity(subtitleOpacity)
                }

                ProgressView()
                    .scaleEffect(1.2)
                    .tint(.black.opacity(0.8))
                    .padding(.top, 8)
                    .opacity(subtitleOpacity)
            }
        }
        .onAppear {
            animateLogo()
        }
    }

    private func animateLogo() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.3)) {
            logoScale = 1.0
            logoOpacity = 1
            offsetY = 0
        }
        
        withAnimation(.easeOut(duration: 0.8).delay(0.4)) {
            subtitleOpacity = 1
        }
    }
}
