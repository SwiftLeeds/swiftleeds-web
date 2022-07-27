//
//  Event.swift
//  
//
//  Created by Joe Williams on 10/04/2022.
//

import Foundation
import Fluent
import Vapor

final class Event: Model, Content {
    
    static let schema = Schema.event

    typealias IDValue = UUID

    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "event_date")
    var date: Date
    
    @Field(key: "location")
    var location: String
    
    @Children(for: \.$event)
    var presentations: [Presentation]

    @Children(for: \.$event)
    var slots: [Slot]
    
    init() { }
}
