//
//  Presentation.swift
//  
//
//  Created by Alex Logan on 19/03/2022.
//

import Foundation
import Vapor
import Fluent

final class Presentation: Model, Content {
        
    typealias IDValue = UUID
    
    static var schema: String {
        return "presentations"
    }
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "synopsis")
    var synopsis: String
    
    @Field(key: "image")
    var image: String?
    
    @Parent(key: "speaker_id")
    var speaker: Speaker
    
    @Parent(key: "event_id")
    public var event: Event

    @Parent(key: "slot_id")
    public var slot: Slot
    
    @Field(key: "is_tba")
    var isTBA: Bool
    
    init() { }
    
    init(id: IDValue?, title: String, synopsis: String, image: String?, isTBA: Bool) {
        self.id = id
        self.title = title
        self.synopsis = synopsis
        self.image = image
        self.isTBA = isTBA
    }
}
