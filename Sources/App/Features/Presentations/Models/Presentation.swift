import Fluent
import Foundation
import Vapor

final class Presentation: Model, Content {
    static var schema = Schema.presentation

    typealias IDValue = UUID
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "synopsis")
    var synopsis: String
    
    @Parent(key: "speaker_id")
    var speaker: Speaker

    @OptionalParent(key: "speaker_two_id")
    var secondSpeaker: Speaker?
    
    @Parent(key: "event_id")
    public var event: Event

    @OptionalParent(key: "slot_id")
    public var slot: Slot?
    
    @Field(key: "is_tba")
    var isTBA: Bool

    @Field(key: "slido_url")
    var slidoURL: String?
    
    init() {}
    
    init(id: IDValue?, title: String, synopsis: String, isTBA: Bool, slidoURL: String?) {
        self.id = id
        self.title = title
        self.synopsis = synopsis
        self.isTBA = isTBA
        self.slidoURL = slidoURL
    }
}
