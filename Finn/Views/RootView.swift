import SwiftUI

struct RootView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var app: AppState
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        NavigationStack {
            Group {
                if !auth.isLoggedIn {
                    IntroView()
                } else if !app.isAppReady {
                    SplashView()
                        .task {
                            await app.preloadInitialData()
                        }
                } else if !settings.isSettedFirstBudeget {
                    CreateBudgetView(
                        budget: nil, onSuccess: {
                            settings.isSettedFirstBudeget = true
                        }
                    )
                } else {
                    MainView()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("FCMToken"))) { noti in
            print("Token từ RootView: \(noti.userInfo?["token"] ?? "")")
        }
    }
}
