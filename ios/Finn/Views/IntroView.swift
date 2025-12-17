import SwiftUI

struct IntroView: View {
    @StateObject private var viewModel = IntroViewModel()
    @EnvironmentObject var settings: AppSettings
    
    init() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.black
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.7)
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "654EA3"),
                    Color(hex: "EAAFC8")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .opacity(0.3)
            .ignoresSafeArea()
            
            TabView(selection: $viewModel.currentPage) {
                ForEach(availableIndices, id: \.self) { index in
                    slideView(for: index)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .tag(index)
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .never))
        }
    }
}

private extension IntroView {
    var availableIndices: [Int] {
        settings.isFirstDownloader
        ? [2]
        : Array(0..<viewModel.screens.count)
    }
    
    @ViewBuilder
    func slideView(for index: Int) -> some View {
        let screen = viewModel.screens[index]
        
        switch index {
        case 0:
            FirstSlideView(
                title: screen.title,
                description: screen.description,
                viewModel: viewModel
            )
        case 1:
            SecondSlideView(
                title: screen.title,
                description: screen.description,
                viewModel: viewModel
            )
        case 2:
            ThirdSlideView(
                title: screen.title,
                description: screen.description,
                viewModel: viewModel
            )
        default:
            EmptyView()
        }
    }
}
