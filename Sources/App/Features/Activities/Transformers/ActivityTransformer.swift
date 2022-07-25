//
//  ActivityTransformer.swift
//  
//
//  Created by Alex Logan on 25/07/2022.
//

import Foundation

enum ActivityTransformer: Transformer {
    static func transform(_ entity: Activity?) -> ActivityResponse? {
        guard let entity = entity else {
             return nil
        }
        return .init(
            id: entity.id,
            title: entity.title,
            subtitle: entity.subtitle,
            description: entity.description,
            metadataURL: entity.metadataURL,
            image: entity.image
        )
    }
}
