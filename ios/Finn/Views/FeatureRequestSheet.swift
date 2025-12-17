import SwiftUI

struct FeatureRequestSheet: View {
    @Binding var text: String
    var onClose: () -> Void

    @FocusState private var isFocused: Bool

    @State private var isSubmitting = false
    @State private var showSuccessAlert = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {

            Capsule()
                .fill(Color.gray.opacity(0.25))
                .frame(width: 42, height: 5)
                .padding(.top, 10)

            Text("Gửi đề xuất tính năng")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(hex: "4A4A4A"))

            ZStack(alignment: .topLeading) {
                TextEditor(text: $text)
                    .focused($isFocused)
                    .padding(12)
                    .frame(height: 160)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                    )

                if text.isEmpty {
                    Text("Mô tả yêu cầu của bạn…")
                        .foregroundColor(.secondary)
                        .padding(.top, 20)
                        .padding(.leading, 20)
                }
            }
            .padding(.horizontal)

            Button {
                submitFeedback()
            } label: {
                HStack {
                    Spacer()
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        Text("Gửi yêu cầu")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    Spacer()
                }
                .padding()
                .background(
                    isSubmitDisabled
                    ? Color.gray.opacity(0.25)
                    : Color.black.opacity(0.85)
                )
                .foregroundColor(.white)
                .cornerRadius(16)
                .padding(.horizontal)
                .shadow(
                    color: .black.opacity(isSubmitDisabled ? 0 : 0.15),
                    radius: 6, x: 0, y: 3
                )
            }
            .disabled(isSubmitDisabled)

            Spacer()
        }
        .padding(.vertical, 14)
        .background(
            LinearGradient(
                colors: [
                    Color.white.opacity(0.95),
                    Color.white.opacity(0.85)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .hideKeyboardOnTap()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                isFocused = true
            }
        }
        .overlay(
            HStack {
                Button {
                    onClose()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                }
                Spacer()
            },
            alignment: .topLeading
        )
        .alert("Cảm ơn bạn!", isPresented: $showSuccessAlert) {
            Button("OK") {
                text = ""
                onClose()
            }
        } message: {
            Text("Đề xuất của bạn đã được gửi. Chúng tôi sẽ xem xét và cải thiện ứng dụng tốt hơn.")
        }
        .alert("Có lỗi xảy ra", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private var isSubmitDisabled: Bool {
        isSubmitting || text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func submitFeedback() {
        isSubmitting = true

        Task {
            do {
                try await FeedbackService.shared.createFeedback(
                    description: text.trimmingCharacters(in: .whitespacesAndNewlines)
                )

                await MainActor.run {
                    isSubmitting = false
                    showSuccessAlert = true
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                    errorMessage = "Không thể gửi yêu cầu. Vui lòng thử lại."
                }
            }
        }
    }
}
