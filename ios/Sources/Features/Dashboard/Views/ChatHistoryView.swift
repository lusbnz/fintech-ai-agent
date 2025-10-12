import SwiftUI

struct ChatHistoryView: View {
    @State private var searchText = ""
    @Environment(\.displayScale) private var displayScale

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 8) {
                   HStack {
                       TextField("Search", text: $searchText)
                       Image(systemName: "magnifyingglass")
                           .foregroundColor(.gray)
                   }
                   .padding(.vertical, 10)
                   .padding(.horizontal, 14)
                   .background(Color.white)
                   .cornerRadius(32)

                   Button(action: {}) {
                       Image(systemName: "plus")
                           .foregroundColor(.black)
                           .padding(10)
                           .background(Color.white)
                           .clipShape(Circle())
                   }
               }
               .padding(.horizontal)

                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        Group {
                            Text("Today")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("How to saving money?").bold()
                            Text("Monday breakfast")

                            Text("Yesterday")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.top, 12)
                            Text("Dining at Dongda")

                            Text("7 day ago")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.top, 12)
                            Text("Grocery")
                            Text("Shopping in Mall")
                            Text("Grocery")
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }

                Spacer()
            }
            .padding(.top, 60)
            .frame(width: geometry.size.width * 0.8)
            .frame(maxHeight: .infinity)
            .background(Color(UIColor.systemGray6))
            .ignoresSafeArea(edges: .vertical)
            .shadow(radius: 10)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}
