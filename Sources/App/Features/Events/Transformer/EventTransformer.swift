import Foundation

enum EventTransformer: Transformer {
    static func transform(_ entity: Event?) -> EventResponse? {
        guard let entity = entity, let id = entity.id else {
            return nil
        }
        return .init(
            id: id,
            name: entity.name,
            date: dateFormatter.string(from: entity.date),
            location: entity.location
        )
    }
}

private extension EventTransformer {
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter
    }
}
