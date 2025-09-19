import SwiftUI

struct FirstSlideView: View {
    let title: String
    let description: String
    @ObservedObject var viewModel: IntroViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
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
            
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    Image("intro1")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 150)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 32))
                    
                    Image("intro2")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 150)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 32))
                }
                .padding(.horizontal)
                
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color.gray)
                    .frame(height: 150)
                    .overlay(
                        Image("intro3")
                            .resizable()
                            .scaledToFill()
                            .frame(height: 150)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 32))
                    )
                    .overlay(
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 32)
                                .fill(Color.white)
                                .frame(width: 220)
                                .padding(.leading, 10)
                                .padding(.trailing, 10)
                                .padding(.vertical, 10)
                                .blur(radius: 1)
                            
                            VStack(alignment: .leading) {
                                Text("1000 +")
                                    .font(.system(size: 32))
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                Text("Questions answered daily")
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
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                                .padding(.leading, 130)
                                .padding(.bottom, 5)
                            }
                            .padding(.leading, 30)
                            .padding(.vertical, 20)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    )
                    .padding(.horizontal)
            }
            .padding(.bottom, 40)
        }
    }
}
