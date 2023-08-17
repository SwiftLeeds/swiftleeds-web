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
    var cfpEnabled: Bool = false
    var ticketsEnabled: Bool = false
    var slots: [Slot] = []
    var platinumSponsors: [Sponsor] = []
    var silverSponsors: [Sponsor] = []
    var goldSponsors: [Sponsor] = []
    var dropInSessions: [DropInSession] = []
    var schedule: [[Slot]] = []
}
