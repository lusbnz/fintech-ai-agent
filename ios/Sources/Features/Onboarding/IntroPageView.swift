import SwiftUI

struct IntroPageView: View {
    let page: Intro
    let isCurrentPage: Bool
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                colors: [
                    Color(hex: "654EA3").opacity(0.2),
                    Color(hex: "EAAFC8").opacity(0.2)
                ],
                startPoint: UnitPoint(x: 0.5, y: 0.52),
                endPoint: UnitPoint(x: 0.5, y: 0.93)
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .opacity(isCurrentPage ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.3), value: isCurrentPage)
                
                // Description
                Text(page.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal)
                    .opacity(isCurrentPage ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.3), value: isCurrentPage)
                
                // Grid Layout (2 vuông + 1 chữ nhật)
                HStack(spacing: 15) {
                    // Card 1 (Vuông)
                    CardView(imageName: page.imageName, title: "Chat")
                        .frame(width: 120, height: 120)
                    
                    // Card 2 (Vuông)
                    CardView(imageName: "message_icon", title: "Messages")
                        .frame(width: 120, height: 120)
                    
                    // Card 3 (Chữ nhật)
                    CardView(imageName: "clock_icon", title: "Speed")
                        .frame(width: 150, height: 120)
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .padding()
        }
    }
    
    // Card View with Blur Effect
    private struct CardView: View {
        let imageName: String
        let title: String
        
        var body: some View {
            ZStack {
                // Blur Background
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .background(VisualEffectView())
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                
                VStack(spacing: 10) {
                    Image(systemName: imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding()
            }
        }
    }
    
    // Custom Visual Effect View for Blur
    private struct VisualEffectView: UIViewRepresentable {
        func makeUIView(context: Context) -> UIVisualEffectView {
            let effect = UIBlurEffect(style: .systemThinMaterialDark)
            return UIVisualEffectView(effect: effect)
        }
        
        func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
    }
}

// Extension to support hex color
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
