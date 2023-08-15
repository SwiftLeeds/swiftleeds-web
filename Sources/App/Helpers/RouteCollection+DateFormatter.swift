import Foundation
import Vapor

extension RouteCollection {
    public static func formDateTimeFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyy-MM-dd'T'HH:mm"
        return dateFormatter
    }

    public static func formDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyy-MM-dd"
        return dateFormatter
    }

    public static func timeFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter
    }
}
