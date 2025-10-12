import Foundation
import Vapor

public extension RouteCollection {
    static func formDateTimeFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        dateFormatter.timeZone = .init(identifier: "UTC")
        return dateFormatter
    }

    static func formDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }

    static func timeFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = .init(identifier: "UTC")
        return dateFormatter
    }
}
