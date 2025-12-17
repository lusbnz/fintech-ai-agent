import SwiftUI
enum Tabs: Int {
    case home = 0, transaction, chat, dashboard, setting
}

struct MainView: View {
    @EnvironmentObject var settings: AppSettings
    @State private var activeTab = Tabs.home
    @State private var showChatView = false
    @State private var showCreateTransaction = false
    
    var body: some View {
        ZStack {
            TabView(selection: $activeTab) {
                HomeView()
                    .tabItem {
                        Label("Trang chủ", systemImage: "tray")
                    }
                    .tag(Tabs.home)
                TransactionView()
                    .tabItem {
                        Label("Giao dịch", systemImage: "list.bullet")
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
                DashboardView()
                    .tabItem {
                        Label("Báo cáo", systemImage: "waveform")
                    }
                    .tag(Tabs.dashboard)
                SettingsView()
                    .tabItem {
                        Label("Cài đặt", systemImage: "gearshape.fill")
                    }
                    .tag(Tabs.setting)
            }
            
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
        .environmentObject(settings)
        .fullScreenCover(isPresented: $showCreateTransaction) {
            NavigationStack {
                CreateTransactionView()
            }
        }
        .fullScreenCover(isPresented: $showChatView) {
            ChatView()
                .onDisappear {
                    activeTab = .home
                }
        }
    }
}
