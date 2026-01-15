import SwiftUI
import Foundation
import Combine
import MapKit

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

extension Int {
    var formattedWithSeparator: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

extension Double {
    func formatVND() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₫"
        formatter.maximumFractionDigits = 0
        formatter.locale = Locale(identifier: "vi_VN")
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

extension View {
    func onKeyboardChange(_ action: @escaping (CGFloat) -> Void) -> some View {
        self
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notif in
                if let frame = notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    action(frame.height)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                action(0)
            }
    }
}

extension UIApplication {
    func hideKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension Transaction {
    var displayDate: Date? {
          let formatter = ISO8601DateFormatter()
          formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

          guard let utcDate = formatter.date(from: date_time) else {
              return nil
          }

          let vnTimeZone = TimeZone(identifier: "Asia/Ho_Chi_Minh")!
          let seconds = TimeInterval(vnTimeZone.secondsFromGMT(for: utcDate))

          return Date(timeInterval: seconds, since: utcDate)
      }

    var formattedDate: String {
        guard let date = displayDate else {
            return "Invalid Date"
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.timeZone = TimeZone(identifier: "Asia/Ho_Chi_Minh")
        formatter.dateFormat = "EEE, MMM d"

        let result = formatter.string(from: date)

        return result
    }
    var timeString: String {
        guard let date = displayDate else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.timeZone = TimeZone(identifier: "Asia/Ho_Chi_Minh")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

extension TransactionReccurring {

    private var vnTimeZone: TimeZone {
        TimeZone(identifier: "Asia/Ho_Chi_Minh")!
    }

    private var isoFormatter: ISO8601DateFormatter {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }

    private func parseDate(_ value: String?) -> Date? {
        guard let value,
              let utcDate = isoFormatter.date(from: value)
        else { return nil }

        let seconds = TimeInterval(vnTimeZone.secondsFromGMT(for: utcDate))
        return Date(timeInterval: seconds, since: utcDate)
    }

    var displayDate: Date? {
        parseDate(created_at)
    }

    var lastRun: Date? {
        parseDate(last_run_at)
    }

    var formattedDate: String {
        formatDate(displayDate)
    }

    var formattedLastRun: String {
        formatDate(lastRun)
    }

    var timeString: String {
        formatTime(displayDate)
    }

    private func formatDate(_ date: Date?) -> String {
        guard let date else { return "—" }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.timeZone = vnTimeZone
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: date)
    }

    private func formatTime(_ date: Date?) -> String {
        guard let date else { return "" }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.timeZone = vnTimeZone
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

extension MKCoordinateRegion {
    static var ptitHaDong: MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 20.980153, longitude: 105.787545),
            latitudinalMeters: 1500,
            longitudinalMeters: 1500
        )
    }
}
