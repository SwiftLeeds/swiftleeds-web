import Fluent
import Foundation
import Vapor

final class Presentation: Model, Content, @unchecked Sendable {
    static let schema = Schema.presentation

    typealias IDValue = UUID
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "synopsis")
    var synopsis: String
    
    @Field(key: "duration")
    var duration: Double
    
    @Parent(key: "speaker_id")
    var speaker: Speaker

    @OptionalParent(key: "speaker_two_id")
    var secondSpeaker: Speaker?
    
    @Parent(key: "event_id")
    var event: Event
    
    @Field(key: "is_tba")
    var isTBA: Bool

    @Field(key: "slido_url")
    var slidoURL: String?

    @Field(key: "video_url")
    var videoURL: String?
    
    @Field(key: "video_visibility")
    var videoVisibility: VideoVisibility?
    
    init() {}
    
    init(id: IDValue?, title: String, synopsis: String, isTBA: Bool, slidoURL: String?, videoURL: String?) {
        self.id = id
        self.title = title
        self.synopsis = synopsis
        self.isTBA = isTBA
        self.slidoURL = slidoURL
        self.videoURL = videoURL
    }
    
    enum VideoVisibility: String, Codable {
        case unlisted
        case shared
        case attendee
    }
}
