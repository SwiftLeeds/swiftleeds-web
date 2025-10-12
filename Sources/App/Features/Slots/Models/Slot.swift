import Fluent
import Foundation
import Vapor

final class Slot: Codable, Model, Content, @unchecked Sendable {
    static let schema = Schema.slot

    typealias IDValue = UUID

    @ID(key: .id)
    var id: UUID?

    @Field(key: "start_date")
    var startDate: String

    @Field(key: "duration")
    var duration: Double?
    
    @OptionalParent(key: "day_id")
    var day: EventDay?

    @OptionalParent(key: "presentation_id")
    var presentation: Presentation?

    @OptionalParent(key: "activity_id")
    var activity: Activity?

    init() {}

    init(
        id: IDValue?,
        startDate: String,
        duration: Double?
    ) {
        self.id = id
        self.startDate = startDate
        self.duration = duration
    }
}

extension [Slot] {
    var schedule: [[Slot]] {
        let dates = Set(compactMap { $0.day?.date.withoutTime }).sorted()
        var slots: [[Slot]] = []

        for date in dates {
            slots.append(
                filter {
                    guard let slotDate = $0.day?.date else {
                        return false
                    }
                    return Calendar.current.isDate(slotDate, inSameDayAs: date)
                }
            )
        }

        return slots
    }
}

extension Date {
    var withoutTime: Date {
        guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: self)) else {
            fatalError("Failed to strip time from Date")
        }

        return date
    }
}
