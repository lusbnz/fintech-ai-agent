import SwiftUI

struct ChatHistoryView: View {
    @State private var searchText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Search bar
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Value", text: $searchText)
                }
                .padding(10)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)

                Button(action: {}) {
                    Image(systemName: "plus")
                        .foregroundColor(.black)
                        .padding(10)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                }
            }
            .padding(.horizontal)

            // History section
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Group {
                        Text("Today")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("How to saving money?").bold()
                        Text("Monday breakfast")

                        Text("Yesterday")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                        Text("Dining at Dongda")

                        Text("7 day ago")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                        Text("Grocery").bold()
                        Text("Shopping in Mall").bold()
                        Text("Grocery")
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }

            Spacer()
        }
        .padding(.top, 60)
        .frame(width: UIScreen.main.bounds.width * 0.8)
        .frame(maxHeight: .infinity)
        .background(Color(UIColor.systemGray6))
        .ignoresSafeArea(edges: .vertical)
        .shadow(radius: 10)
    }
}
