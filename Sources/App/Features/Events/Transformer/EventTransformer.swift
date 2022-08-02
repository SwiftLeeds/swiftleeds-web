//
//  EventTransformer.swift
//  
//
//  Created by Alex Logan on 02/08/2022.
//

import Foundation

enum EventTransformer: Transformer {
    static func transform(_ entity: Event?) -> EventResponse? {
        guard let entity = entity else { return nil }
        return .init(
            id: entity.id,
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
