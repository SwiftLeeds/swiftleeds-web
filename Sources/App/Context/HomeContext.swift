import Foundation
import Vapor

/// Placeholder context for the home page.
///
/// Usage:
///
///     let cfpExpirationDate = Date(timeIntervalSince1970: 1651356000) // 30th April 22
///     let speakers: [Speaker] = Speaker.speakers // This should be populated from a database
///     return req.view.render("Home/home", HomeContext(speakers: speakers, cfpActive: Date() < cfpExpirationDate))
///
struct HomeContext: Content {
    var speakers: [Speaker] = []
    var platinumSponsors: [Sponsor] = []
    var silverSponsors: [Sponsor] = []
    var goldSponsors: [Sponsor] = []
    var dropInSessions: [DropInSession] = []
    var schedule: [ScheduleDay] = []
    var phase: PhaseContext? = nil
    var event: Event? = nil
    var eventDate: String? = nil
    var eventYear: String? = nil
}

struct ScheduleDay: Codable {
    let name: String
    let date: Date
    let slots: [Slot]
}

struct CfpContext: Content {
    struct Question: Codable {
        let question: String
        let answer: [String]
    }
    
    struct Stage: Codable {
        let now: Date
        let openDate: Date
        let closeDate: Date
        let reviewCompleted: Bool
        let cfpUrl: String
    }
    
    let stage: Stage
    var faqs: [Question] = []
    var phase: PhaseContext? = nil
    var event: Event? = nil
    var eventDate: String? = nil
    var eventYear: String? = nil
}

struct TeamContext: Content {
    struct TeamMember: Codable {
        let name: String
        let role: String?
        let twitter: String?
        let linkedin: String?
        let imageURL: String?
    }
    
    var teamMembers: [TeamMember] = []
    var event: Event? = nil
    var eventDate: String? = nil
    var eventYear: String? = nil
}
