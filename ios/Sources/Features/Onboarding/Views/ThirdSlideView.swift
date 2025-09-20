import SwiftUI

struct ThirdSlideView: View {
    let title: String
    let description: String
    @ObservedObject var viewModel: IntroViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Image("intro5")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: 400)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 36))
                .padding(.horizontal)
                .overlay(
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 32)
                            .fill(Color.white)
                            .frame(width: 220, height: 150)
                            .padding(.leading, 10)
                            .padding(.trailing, 10)
                            .padding(.vertical, 15)
                            .blur(radius: 1)
                        
                        VStack(alignment: .leading) {
                            Text("5000 +")
                                .font(.system(size: 32))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            Text("Daily users")
                                .font(.system(size: 14))
                                .fontWeight(.medium)
                                .foregroundColor(.black)
                            Button(action: {
                                print("Button tapped")
                            }) {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 20))
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .rotationEffect(.degrees(-45))
                                    .frame(width: 50, height: 50)
                                    .background(
                                        Circle()
                                            .fill(Color.black.opacity(0.7))
                                    )
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .padding(.leading, 130)
                            .padding(.top, 10)
                        }
                        .padding(.leading, 30)
                        .padding(.vertical, 30)
                    }
                    .padding(.leading, 20)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                )
            
            Spacer()
            
            Text(title)
                .font(.system(size: 36))
                .fontWeight(.bold)
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
                .padding(.horizontal)
            
            Text(description)
                .font(.system(size: 16))
                .fontWeight(.medium)
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
                .padding(.horizontal)
                .lineSpacing(5)
                        
            Spacer()

            HStack(spacing: 12) {
                Spacer()
                
                Button(action: {
                    print("Apple Login tapped")
                }) {
                    Image(systemName: "apple.logo")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(width: 80, height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 32)
                                .fill(Color.black)
                        )
                }
                
                Button(action: {
                    print("Google Login tapped")
                }) {
                    Image(systemName: "g.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.orange)
                        .frame(width: 80, height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 32)
                                .fill(Color.white)
                        )
                }
                
                Button(action: {
                    print("Facebook Login tapped")
                }) {
                    Image(systemName: "f.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(width: 80, height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 32)
                                .fill(Color.blue)
                        )
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
            .padding(.top, 100)
        }
    }
}
