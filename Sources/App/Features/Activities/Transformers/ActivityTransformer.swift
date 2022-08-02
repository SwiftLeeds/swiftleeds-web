//
//  ActivityTransformer.swift
//  
//
//  Created by Alex Logan on 25/07/2022.
//

import Foundation

enum ActivityTransformer: Transformer {
    static func transform(_ entity: Activity?) -> ActivityResponse? {
        guard let entity = entity, let id = entity.id else { return nil }
        return .init(
            id: id,
            title: entity.title,
            subtitle: entity.subtitle,
            description: entity.$description.wrappedValue ?? "", // Avoid name conflict with description
            metadataURL: entity.metadataURL,
            image: entity.image
        )
    }
}
