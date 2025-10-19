import SwiftUI

struct ChallengeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "E8F3E8"),
                    Color(hex: "FFFFFF")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
               
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Hi, \(authViewModel.userProfile?.display_name ?? "Guest")!")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.black)

                            Text("Sun, October 15")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 12) {
                            NavigationLink {
                                SettingView(authViewModel: authViewModel)
                            } label: {
                                Image(systemName: "gearshape")
                                    .font(.system(size: 16))
                                    .foregroundColor(.black)
                                    .padding(6)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 10) {
                        ForEach(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"], id: \.self) { day in
                            VStack(spacing: 6) {
                                Text(day)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.gray)
                                ZStack {
                                    Circle()
                                        .fill(day == "Fri" ? Color.gray.opacity(0.3) : Color.white)
                                        .frame(width: 40, height: 40)
                                        .shadow(radius: 1)
                                    Text(day == "Fri" ? "21" : day == "Mon" ? "17" :
                                            day == "Tue" ? "18" :
                                            day == "Wed" ? "19" :
                                            day == "Thu" ? "20" :
                                            day == "Sat" ? "22" : "23")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.black)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.yellow.opacity(0.15))
                    .cornerRadius(20)
                }
                
                Spacer()

                VStack(alignment: .leading, spacing: 12) {
                    Text("Daily Highlights")
                        .font(.system(size: 20, weight: .semibold))
                    
                    NavigationLink(destination: StatisticsView()) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("$ 68.70")
                                .font(.system(size: 24, weight: .semibold))
                            Text("Save 1 bubble tea cup per day")
                                .foregroundColor(.black)
                                .font(.system(size: 14))
                            HStack {
                                Text("1 day to go")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("$233.00 saved")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            ProgressView(value: 0.3)
                                .tint(.blue)
                                .padding(.top, 4)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()

                VStack(alignment: .leading, spacing: 16) {
                    Text("Realtime Challenge")
                        .font(.system(size: 20, weight: .semibold))

                    ChallengeCardView(
                        title: "7-day Starbuck Challenge",
                        subtitle: "Save your wallet without Starbuck.",
                        buttonTitle: "Join now",
                        timer: "2:23:45",
                        backgroundColor: Color(hex: "DCD6F7")
                    )

                    ChallengeCardView(
                        title: "30-day Saving Money Challenge",
                        subtitle: "Starting in day 1! Enable notifications to make sure you dont miss it!",
                        buttonTitle: "Notify me",
                        timer: "Start in 2:23:45",
                        backgroundColor: Color(hex: "F7EBD6")
                    )
                }
            }
            .padding(.horizontal, 20)
        }
        .navigationBarHidden(true)
    }
}

struct ChallengeCardView: View {
    var title: String
    var subtitle: String
    var buttonTitle: String
    var timer: String
    var backgroundColor: Color

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                Button {
                    // Action
                } label: {
                    Text(buttonTitle)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.black)
                        .cornerRadius(20)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                Image(systemName: "banknote")
                    .font(.system(size: 20))
                    .rotationEffect(.degrees(-10))
                
                Spacer()
                
                Text(timer)
                   .font(.system(size: 12))
                   .foregroundColor(.gray)
                   .padding(6)
                   .overlay(
                       RoundedRectangle(cornerRadius: 32)
                           .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                   )
            }
        }
        .padding()
        .background(backgroundColor.opacity(0.5))
        .cornerRadius(20)
    }
}
