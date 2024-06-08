import Foundation
import Vapor

extension RouteCollection {
    public static func formDateTimeFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        dateFormatter.timeZone = .init(identifier: "UTC")
        return dateFormatter
    }

    public static func formDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }

    public static func timeFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = .init(identifier: "UTC")
        return dateFormatter
    }
}
