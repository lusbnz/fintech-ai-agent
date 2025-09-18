import SwiftUI

struct IntroView: View {
    @StateObject private var viewModel = IntroViewModel()
    
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
            .ignoresSafeArea(.all)
            
            TabView(selection: $viewModel.currentPage) {
                ForEach(0..<viewModel.screens.count, id: \.self) { index in
                    Group {
                        if index == 0 {
                            FirstSlideView(title: viewModel.screens[index].title, description: viewModel.screens[index].description)
                        } else if index == 1 {
                            SecondSlideView(title: viewModel.screens[index].title, description: viewModel.screens[index].description)
                        } else if index == 2 {
                            ThirdSlideView(title: viewModel.screens[index].title, description: viewModel.screens[index].description)
                        }
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .tag(index)
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .never))
        }
    }
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView()
    }
}
