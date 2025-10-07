import SwiftUI

enum Tabs: Int {
    case home = 0, transaction, chat
}

struct WrapperView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var activeTab = Tabs.home
    
    var body: some View {
        TabView(selection: $activeTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "tray.fill")
                }
                .tag(Tabs.home)
            
            TransactionView()
                .tabItem {
                    Label("Transaction", systemImage: "list.bullet")
                }
                .tag(Tabs.transaction)
            
            ChatView()
                .tabItem {
                    Label("Chat", systemImage: "bubbles.and.sparkles")
                }
                .tag(Tabs.chat)
                
        }
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}
