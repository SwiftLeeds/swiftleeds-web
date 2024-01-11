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
    var schedule: [[Slot]] = []
    var phase: PhaseContext? = nil
    var event: Event? = nil
    var eventDate: String? = nil
    var eventYear: String? = nil
}

struct CfpContext: Content {
    struct Question: Codable {
        let question: String
        let answer: [String]
    }
    
    var faqs: [Question] = []
    var phase: PhaseContext? = nil
    var event: Event? = nil
    var eventDate: String? = nil
    var eventYear: String? = nil
}
