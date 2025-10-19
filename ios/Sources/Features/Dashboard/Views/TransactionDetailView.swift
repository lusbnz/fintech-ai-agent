import SwiftUI

struct TransactionDetailView: View {
    let transaction: Transaction
    @Environment(\.dismiss) var dismiss
    @State private var showMenu = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(10)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                    Spacer()
                    Menu {
                        Button("Edit", systemImage: "pencil") { }
                        Button("Delete", systemImage: "trash", role: .destructive) { }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(10)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("19 Aug 2025")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.black)
                    Text(transaction.title)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.black)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 24) {
                    timelineRow(icon: "mappin.and.ellipse", title: transaction.place)
                    timelineRow(icon: "tag", title: "Shopping")
                    timelineRow(icon: "hand.thumbsup", title: "Tổng chi tiêu", value: transaction.amount)
                    
                    numberedRow(number: 1, title: "Cam sành", value: "20,000 VNĐ")
                    imageSection(icon: "photo.on.rectangle", imageName: "intro1", time: "18:25")
                    numberedRow(number: 2, title: "Thanh long", value: "35,000 VNĐ")
                }
                .padding(.horizontal)
                .padding(.leading, 6)
                
                Spacer(minLength: 20)
            }
            .padding(.bottom, 32)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "EAF0FF"), Color.white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func timelineRow(icon: String, title: String, value: String? = nil) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack {
                iconCircle(content: .icon(icon))
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 1)
                    .frame(maxHeight: .infinity)
                    .padding(.top, -4)
                    .padding(.bottom, -20)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                if let value = value {
                    Text(value)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
            }
            Spacer()
        }
    }
    
    func numberedRow(number: Int, title: String, value: String? = nil) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack {
                iconCircle(content: .text("\(number)"))
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 1)
                    .frame(maxHeight: .infinity)
                    .padding(.top, -4)
                    .padding(.bottom, -20)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                if let value = value {
                    Text(value)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
            }
            Spacer()
        }
    }
    
    @ViewBuilder
    func imageSection(icon: String, imageName: String, time: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack {
                iconCircle(content: .icon(icon))
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 1)
                    .frame(maxHeight: .infinity)
                    .padding(.top, -4)
                    .padding(.bottom, -20)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 260)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .shadow(color: .clear, radius: 0)
                Text(time)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
        .padding(.trailing, 16)
    }
    
    enum IconContent {
        case icon(String)
        case text(String)
    }
    
    @ViewBuilder
    func iconCircle(content: IconContent) -> some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .overlay(Circle().stroke(Color.gray.opacity(0.25), lineWidth: 1))
                .frame(width: 28, height: 28)
            
            switch content {
            case .icon(let system):
                Image(systemName: system)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.gray)
            case .text(let text):
                Text(text)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.gray)
            }
        }
    }
}
