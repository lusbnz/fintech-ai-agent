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
    @State private var messages: [ChatMessage] = []
    @State private var inputText: String = ""
    @State private var showInsight: Bool = false
    @State private var showHistory = false
    @Namespace private var transitionNamespace

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // ===== HEADER =====
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(8)
                    }

                    Spacer()
                    Spacer()

                    VStack(spacing: 2) {
                        Text("AI Assistant")
                            .font(.system(size: 16, weight: .semibold))
                        Text("4/9998")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    // ➕ Nút tạo chat mới
                    Button(action: createNewChat) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(8)
                    }

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

                if messages.isEmpty {
                    VStack(spacing: 8) {
                        Text("Meet Your Budget Coach")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.primary)

                        Text("Locally AI now supports on-device large language model, the same model that powers intelligence.")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(messages) { message in
                                    ChatBubble(message: message)
                                }

                                if showInsight {

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
                }

                if !showInsight && !messages.isEmpty {
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
                        HStack(spacing: 8) {
                            HStack {
                                TextField("Ask anything", text: $inputText)
                                    .font(.system(size: 16))
                                    .foregroundColor(.primary)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                                    .onSubmit { sendMessage() }
                            }
                            .background(Color.white)
                            .clipShape(Capsule())
                            .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)

                            Button(action: sendMessage) {
                                Image(systemName: "mic.fill")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 42, height: 42)
                                    .background(Circle().fill(Color.black))
                            }
                        }
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

    func createNewChat() {
        withAnimation(.spring()) {
            messages.removeAll()
            inputText = ""
            showInsight = false
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
