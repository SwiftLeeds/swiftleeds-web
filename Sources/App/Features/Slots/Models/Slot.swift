import Fluent
import Foundation
import Vapor

final class Slot: Codable, Model, Content {
    static let schema = Schema.slot

    typealias IDValue = UUID

    @ID(key: .id)
    var id: UUID?

    @Field(key: "start_date")
    var startDate: String
    
    @Field(key: "date")
    var date: Date?

    @Field(key: "duration")
    var duration: Double

    @Parent(key: "event_id")
    var event: Event

    @OptionalChild(for: \.$slot)
    var presentation: Presentation?

    @OptionalChild(for: \.$slot)
    var activity: Activity?

    init() {}

    init(
        id: IDValue?,
        startDate: String,
        date: Date,
        duration: Double
    ) {
        self.id = id
        self.startDate = startDate
        self.date = date
        self.duration = duration
    }
}

extension Array where Element == Slot {
    var schedule: [[Slot]] {
        let dates = Set(compactMap { $0.date?.withoutTime }).sorted(by: (<))
        var slots: [[Slot]] = []

        for date in dates {
            slots.append(filter { Calendar.current.compare(date, to: $0.date ?? Date(), toGranularity: .day) == .orderedSame })
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
