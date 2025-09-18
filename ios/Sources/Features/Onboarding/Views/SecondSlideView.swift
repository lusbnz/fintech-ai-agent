import SwiftUI

struct SecondSlideView: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Image("intro4")
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
                            Text("2")
                                .font(.system(size: 32))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            Text("Seconds to get an answer")
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

            Button(action: {
                print("Button tapped")
            }) {
                ZStack(alignment: .leading) {
                    Text("Get started now")
                        .font(.system(size: 14))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 32)
                                .fill(Color.black)
                                .opacity(0.7)
                        )
                    
                    Button(action: {
                        print("Button tapped")
                    }) {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 20))
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(width: 42, height: 42)
                            .background(
                                Circle()
                                    .fill(Color.black)
                            )
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
            .padding(.top, 100)
        }
    }
}
