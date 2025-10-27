import SwiftUI

enum Tabs: Int {
    case home = 0, transaction, chat, challenge
}

struct WrapperView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var activeTab = Tabs.home
    @State private var showChatView = false
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
            
                Color.clear
                    .tabItem {
                        Label("Chat", systemImage: "bubbles.and.sparkles")
                    }
                    .tag(Tabs.chat)
                    .onAppear {
                        showChatView = true
                    }
                
//                ChallengeView()
//                    .tabItem {
//                        Label("Challenge", systemImage: "paperplane")
//                    }
//                    .tag(Tabs.challenge)
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
                }
                .padding(.bottom, 60)
                .padding(.trailing, 30)
            }
        }
        .fullScreenCover(isPresented: $showChatView) {
            ChatView()
                .onDisappear {
                    activeTab = .home 
                }
        }
        .fullScreenCover(isPresented: $showCreateTransaction) {
            NavigationStack {
                CreateTransactionView()
            }
        }
        .task {
            await authViewModel.fetchProfile()
        }
        .environmentObject(authViewModel)
    }
}
