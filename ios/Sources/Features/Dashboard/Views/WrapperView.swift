import SwiftUI

enum Tabs: Int {
    case home = 0, transaction, chat, create_transaction, challenge
}

struct WrapperView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var activeTab = Tabs.home
    @State private var showCreateTransaction = false
    
    var body: some View {
        ZStack {
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
                
                ChallengeView()
                    .tabItem {
                        Label("Challenge", systemImage: "paperplane")
                    }
                    .tag(Tabs.challenge)
                
            }
            .tabBarMinimizeBehavior(.onScrollDown)
            
            VStack {
               Spacer()
               HStack {
                   Spacer()
                   Button(action: {
                       showCreateTransaction = true
                   }) {
                       Image(systemName: "plus")
                           .font(.system(size: 28, weight: .bold))
                           .foregroundColor(.white)
                           .frame(width: 60, height: 60)
                           .background(
                               Circle()
                                   .fill(
                                       LinearGradient(
                                           gradient: Gradient(colors: [.blue, .purple]),
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing
                                       )
                                   )
                                   .shadow(radius: 8)
                           )
                   }
                   Spacer()
               }
               .padding(.bottom, 25)
           }
           .sheet(isPresented: $showCreateTransaction) {
               CreateTransactionView()
           }
        }
    }
}
