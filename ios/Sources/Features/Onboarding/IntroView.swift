import SwiftUI

struct IntroView: View {
    @StateObject private var viewModel = IntroViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Page View
            TabView(selection: $viewModel.currentPage) {
                ForEach(0..<viewModel.pages.count, id: \.self) { index in
                    IntroPageView(
                        page: viewModel.pages[index],
                        isCurrentPage: viewModel.currentPage == index
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.5), value: viewModel.currentPage)
            
            // Bottom Navigation Bar
            VStack {
                Spacer()
                HStack(spacing: 20) {
                    // Skip Button
                    Button(action: {
                        viewModel.goToLogin()
                    }) {
                        Text("Skip")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    // Next Button
                    Button(action: {
                        viewModel.nextPage()
                    }) {
                        HStack {
                            Text(viewModel.currentPage < viewModel.totalPages - 1 ? "Next" : "Get Started")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
                .background(Color(.systemBackground).opacity(0.95))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 20)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
            }
        }
        .ignoresSafeArea(.keyboard)
        .fullScreenCover(isPresented: $viewModel.showLogin) {
            LoginView()
        }
    }
}

// MARK: - Preview
struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView()
    }
}
