import SwiftUI
import PhotosUI

struct ChatMessage: Identifiable {
    let id: String
    let text: String
    let image: String?
    let isUser: Bool
    let time: String
    let card: MessageCard?
}

extension Chat {
    func toChatMessage() -> ChatMessage {
        ChatMessage(
            id: id,
            text: message.text,
            image: message.image,
            isUser: is_me,
            time: created_at.formatChatTime(),
            card: message.card?.first
        )
    }
}

extension String {
    func formatChatTime() -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = isoFormatter.date(from: self) else {
            return "Invalid date"
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        
        if calendar.isDateInToday(date) {
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: date)
        } else {
            let components = calendar.dateComponents([.year], from: date, to: now)
            if components.year == 0 {
                formatter.dateFormat = "dd/MM"
            } else {
                formatter.dateFormat = "dd/MM/yyyy"
            }
            return formatter.string(from: date)
        }
    }
}

struct ChatView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var app: AppState
    @EnvironmentObject var chatViewModel: ChatViewModel
    
    @State private var inputText: String = ""
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @Namespace private var transitionNamespace
    
    // MARK: - Image Selection States
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    
    private let suggestions: [String] = [
        "Hôm nay tôi chi bao nhiêu?",
        "Tổng thu nhập tháng này",
        "Phân tích chi tiêu tuần qua",
        "Ghi chi 50k ăn sáng",
        "Ghi thu 10 triệu lương",
        "So sánh chi tiêu tháng này và tháng trước",
        "Danh mục nào tốn nhiều nhất?",
        "Tôi còn bao nhiêu tiền?"
    ]
    
    private var messages: [ChatMessage] {
        app.chats.map { $0.toChatMessage() }
    }
    
    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty || selectedImage != nil else { return }

        inputText = ""
        let imageToUpload = selectedImage
        selectedImage = nil
        selectedPhotoItem = nil
        speechRecognizer.reset()

        Task {
            do {
                var imageUrl: String = ""

                if let image = imageToUpload {
                    imageUrl = try await TransactionService.shared.uploadImage(image)
                    print("Uploaded image URL:", imageUrl ?? "")
                }

                await chatViewModel.sendMessage(
                    text,
                    image: imageUrl
                )

            } catch {
                print("Send message failed:", error)
            }
        }
    }

    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    Text("Trợ lý AI")
                        .font(.system(size: 16, weight: .semibold))
                    Spacer()
                    Spacer().frame(width: 16)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Empty state
                if messages.isEmpty {
                    VStack(spacing: 8) {
                        Text("Meet Your Budget Coach")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text("Locally AI now supports on-device large language model, the same model that powers intelligence.")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                } else {
                    // Chat messages
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20) {
                                ForEach(messages.reversed()) { message in
                                    ChatBubble(message: message)
                                }
                                
                                Color.clear
                                    .frame(height: 1)
                                    .id("Bottom")
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                            .padding(.bottom, 60)
                        }
                        .onChange(of: messages.count) { _ in
                            withAnimation {
                                proxy.scrollTo("Bottom", anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Input Area
                VStack(spacing: 0) {
                    if speechRecognizer.isRecording {
                        RecordingIndicatorView()
                    }
                    
                    SuggestionChipsView(
                        suggestions: suggestions,
                        onSelect: { suggestion in
                            inputText = suggestion
                        }
                    )
                    
                    // Selected Image Preview
                    if let image = selectedImage {
                        HStack {
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 56, height: 56)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)

                                Button {
                                    withAnimation(.spring()) {
                                        selectedImage = nil
                                        selectedPhotoItem = nil
                                    }
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 18, height: 18)
                                        .background(
                                            Circle()
                                                .fill(Color.black.opacity(0.6))
                                        )
                                }
                                .offset(x: 6, y: -6)
                            }

                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                    }

                    
                    // Input Bar
                    HStack(spacing: 8) {
                        // Voice Button
                        VoiceInputButton(
                            isRecording: speechRecognizer.isRecording,
                            isAuthorized: speechRecognizer.isAuthorized
                        ) {
                            speechRecognizer.toggleRecording()
                        }
                        
                        // Photo Picker Button
                        PhotosPicker(
                            selection: $selectedPhotoItem,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 42, height: 42)
                                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                                
                                Image(systemName: "photo.on.rectangle")
                                    .font(.system(size: 18))
                                    .foregroundColor(.black)
                            }
                        }
                        .onChange(of: selectedPhotoItem) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    selectedImage = uiImage
                                }
                            }
                        }
                        
                        // Text Field
                        TextField("Ask anything", text: $inputText)
                            .font(.system(size: 16))
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(Color.white)
                            .clipShape(Capsule())
                            .onSubmit { sendMessage() }
                            .disabled(chatViewModel.isSending)
                        
                        // Send Button
                        Button(action: sendMessage) {
                            if chatViewModel.isSending {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(width: 42, height: 42)
                                    .background(Circle().fill(Color.black.opacity(0.6)))
                            } else {
                                Image(systemName: "paperplane.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                    .frame(width: 42, height: 42)
                                    .background(Circle().fill(Color.black))
                            }
                        }
                        .disabled(chatViewModel.isSending ||
                                  (inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedImage == nil))
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                .background(Color(.systemGray6))
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .navigationBarHidden(true)
            }
            .background(Color(.systemGray6))
            .onTapGesture {
                hideKeyboard()
            }
            .onChange(of: speechRecognizer.transcribedText) { newValue in
                if !newValue.isEmpty {
                    inputText = newValue
                }
            }
            
            // Error Toast
            if let error = chatViewModel.errorMessage ?? speechRecognizer.errorMessage {
                VStack {
                    Text(error)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    Spacer()
                }
                .padding(.top, 60)
                .transition(.move(edge: .top))
                .zIndex(1)
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Supporting Views (unchanged)

struct VoiceInputButton: View {
    let isRecording: Bool
    let isAuthorized: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isRecording ? Color.red : Color.white)
                    .frame(width: 42, height: 42)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                
                if isRecording {
                    Circle()
                        .stroke(Color.red.opacity(0.5), lineWidth: 2)
                        .frame(width: 42, height: 42)
                        .scaleEffect(isRecording ? 1.3 : 1.0)
                        .opacity(isRecording ? 0 : 1)
                        .animation(
                            Animation.easeOut(duration: 1.0).repeatForever(autoreverses: false),
                            value: isRecording
                        )
                }
                
                Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                    .font(.system(size: 18))
                    .foregroundColor(isRecording ? .white : (isAuthorized ? .black : .gray))
            }
        }
        .disabled(!isAuthorized && !isRecording)
    }
}

struct RecordingIndicatorView: View {
    @State private var animateWave = false
    
    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 3) {
                ForEach(0..<5, id: \.self) { index in
                    Capsule()
                        .fill(Color.red)
                        .frame(width: 3, height: animateWave ? CGFloat.random(in: 8...20) : 8)
                        .animation(
                            Animation.easeInOut(duration: 0.3)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.1),
                            value: animateWave
                        )
                }
            }
            
            Text("Đang nghe...")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.red)
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.red.opacity(0.1))
        .onAppear {
            animateWave = true
        }
    }
}

struct SuggestionChipsView: View {
    let suggestions: [String]
    let onSelect: (String) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(suggestions, id: \.self) { suggestion in
                    SuggestionChip(text: suggestion) {
                        onSelect(suggestion)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
    }
}

struct SuggestionChip: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.06), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct OutcomeCardView: View {
    let amount: Double
    let description: String
    
    private var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return formatter.string(from: NSNumber(value: amount)) ?? "\(Int(amount))"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "arrow.up.circle.fill")
                    .foregroundColor(.red)
                Text("Chi tiêu")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.red)
                Spacer()
                Text("-\(formattedAmount) VND")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.red)
            }
            Text(description)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
        )
    }
}

struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        VStack(
            alignment: message.isUser ? .trailing : .leading,
            spacing: 6
        ) {

            if let imageUrl: String = message.image,
               let url = URL(string: imageUrl) {

                HStack {
                    if message.isUser { Spacer() }

                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 200, height: 200)

                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: 240, maxHeight: 240)
                                .clipped()

                        case .failure:
                            Image(systemName: "photo")
                                .frame(width: 200, height: 200)
                                .foregroundColor(.gray)

                        @unknown default:
                            EmptyView()
                        }
                    }
                    .cornerRadius(14)

                    if !message.isUser { Spacer() }
                }
            }

            if !message.text.isEmpty {
                HStack {
                    if message.isUser { Spacer() }

                    Text(message.text)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(
                            message.isUser
                            ? Color.gray.opacity(0.15)
                            : Color.white
                        )
                        .font(.system(size: 13, weight: .medium))
                        .cornerRadius(14)
                        .shadow(
                            color: message.isUser
                            ? .clear
                            : .black.opacity(0.05),
                            radius: 1
                        )

                    if !message.isUser { Spacer() }
                }
            }

            if let card = message.card, card.type == "outcome" {
                HStack {
                    if message.isUser { Spacer() }

                    OutcomeCardView(
                        amount: card.amount,
                        description: card.description
                    )
                    .frame(maxWidth: 300)

                    if !message.isUser { Spacer() }
                }
            }

            Text(message.time)
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .padding(
                    message.isUser ? .trailing : .leading,
                    12
                )
        }
    }
}
