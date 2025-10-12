import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let time: String
}

struct SuggestionItem: Hashable {
    let title: String
    let subtitle: String
}

struct ChatView: View {
    @Environment(\.dismiss) var dismiss
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "Hi, are you looking for something else?", isUser: false, time: "2:13 pm"),
        ChatMessage(text: "Tôi vừa làm bát bún chả 30 nghìn", isUser: true, time: "2:16 pm"),
        ChatMessage(text: "I just recorded your transaction under the category Food, subcategory Breakfast for 30,000 VND.", isUser: false, time: "2:16 pm")
    ]
    
    @State private var inputText: String = ""
    @State private var showInsight: Bool = false
    @State private var showHistory = false
    @Namespace private var transitionNamespace
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(8)
                    }
                    Spacer()
                    Spacer()
                    
                    Text("AI Assistant")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Spacer()
                    
                    Text("4/9998")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.gray)
                    Button(action: {
                        withAnimation(.spring()) {
                            showHistory.toggle()
                        }
                    }) {
                        Image(systemName: "text.alignleft")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(8)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(messages) { message in
                                ChatBubble(message: message)
                            }
                            
                            if showInsight {
                                InsightCard()
                                    .padding(.top, 8)
                                    .transition(.move(edge: .bottom).combined(with: .opacity))
                                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showInsight)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .padding(.bottom, 60)
                        .id("Bottom")
                    }
                    .onChange(of: messages.count) {
                        withAnimation {
                            proxy.scrollTo("Bottom", anchor: .bottom)
                        }
                    }
                }
                
                if !showInsight {
                    FlexibleView(
                        data: [
                            SuggestionItem(title: "Create new Cate", subtitle: "Cate dành cho quần áo"),
                            SuggestionItem(title: "Saving", subtitle: "Tiết kiệm hiệu quả"),
                            SuggestionItem(title: "Shopping", subtitle: "Chi tiêu hợp lý"),
                            SuggestionItem(title: "Food", subtitle: "Ăn uống lành mạnh"),
                            SuggestionItem(title: "Health", subtitle: "Sức khỏe & Gym")
                        ],
                        spacing: 8
                    ) { item in
                        SuggestionButton(title: item.title, subtitle: item.subtitle)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .animation(.easeInOut(duration: 0.3), value: showInsight)
                }
                
                ZStack {
                    if showInsight {
                        HStack(spacing: 12) {
                            Button(action: {}) {
                                Text("Make Change")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.black)
                                    .padding(.vertical, 10)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.gray.opacity(0.15))
                                    .cornerRadius(32)
                            }
                            Button(action: { withAnimation(.spring()) { showInsight = false } }) {
                                Text("Save")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.vertical, 10)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.black)
                                    .cornerRadius(32)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                        .matchedGeometryEffect(id: "inputArea", in: transitionNamespace)
                    } else {
                        HStack(spacing: 12) {
                            Image(systemName: "mic.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                            
                            TextField("Type here ...", text: $inputText)
                                .textFieldStyle(PlainTextFieldStyle())
                                .font(.system(size: 15))
                                .foregroundColor(.primary)
                                .padding(.vertical, 8)
                            
                            Button(action: sendMessage) {
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 32, height: 32)
                                    .background(Circle().fill(Color.black))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 32)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 1)
                        )
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                        .matchedGeometryEffect(id: "inputArea", in: transitionNamespace)
                    }
                }
                .animation(.spring(response: 0.45, dampingFraction: 0.85), value: showInsight)
            }
            .background(Color(.systemGray6))
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .navigationBarHidden(true)
            
            if showHistory {
               Color.black.opacity(0.25)
                   .ignoresSafeArea()
                   .onTapGesture {
                       withAnimation(.spring()) {
                           showHistory = false
                       }
                   }

               ChatHistoryView()
                   .transition(.move(edge: .trailing))
           }
        }
    }
    
    func sendMessage() {
        guard !inputText.isEmpty else { return }
        let newMsg = ChatMessage(text: inputText, isUser: true, time: "2:17 pm")
        messages.append(newMsg)
        inputText = ""
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            messages.append(ChatMessage(
                text: "I just recorded your transaction under the category Food, subcategory Breakfast for 30,000 VND.",
                isUser: false,
                time: "2:17 pm"
            ))
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                showInsight = true
            }
        }
    }
}


struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
            HStack {
                if message.isUser { Spacer() }
                Text(message.text)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(message.isUser ? Color.gray.opacity(0.15) : Color.white)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.black)
                    .cornerRadius(14)
                    .shadow(color: message.isUser ? .clear : Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                if !message.isUser { Spacer() }
            }
            Text(message.time)
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "666666"))
                .padding(message.isUser ? .trailing : .leading, 12)
        }
    }
}

struct SuggestionButton: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
            Text(subtitle)
                .font(.system(size: 10, weight: .regular))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.gray.opacity(0.15))
        .cornerRadius(16)
    }
}

struct InsightCard: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Ăn bún chả")
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
                Text("30,000 VNĐ")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(hex: "A35C00"))
            }
            Spacer()
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.blue, lineWidth: 8)
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: 46, height: 46)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
