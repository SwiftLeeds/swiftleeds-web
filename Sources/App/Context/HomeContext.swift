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
    var event: EventContext? = nil
}

struct EventContext: Codable {
    let name: String // SwiftLeeds 2024
    let event: String // SwiftLeeds
    let year: String // 2024
    
    let date: Date?
    let dateFormatted: String? // 7-10 OCT
    
    let location: String
    
    let isCurrent: Bool
    let isFuture: Bool
    let isPast: Bool
    let isHidden: Bool
    
    init(event: Event) {
        self.name = event.name
        self.event = event.name.components(separatedBy: " ").first ?? "SwiftLeeds"
        self.year = event.name.components(separatedBy: " ").last ?? ""
        
        // This is a total hack, but means if we set the date of an event to something earlier than 2015 then the event is hidden.
        // This prevents people accessing that year, useful for development and preparing.
        // TODO: just make event.date optional in database
        let isKnownDate = event.date.timeIntervalSince1970 > 1420074000
        
        self.date = isKnownDate ? event.date : nil
        self.dateFormatted = isKnownDate ? Self.buildConferenceDateString(for: event) : nil
        
        self.location = event.location
        
        self.isCurrent = event.isCurrent
        self.isFuture = event.date > Date() && !isKnownDate
        self.isPast = event.date <= Date() && isKnownDate
        self.isHidden = isKnownDate != true
    }
    
    private static func buildConferenceDateString(for event: Event) -> String? {
        let date = event.date
        
        let days = event.days
            .filter { $0.name.contains("Talkshow") == false }
            .count
        
        let formatter = DateFormatter()
        formatter.locale = .init(identifier: "en_US_POSIX")
        
        if days == 1 {
            formatter.dateFormat = "d MMM"
            return formatter.string(from: date).uppercased()
        } else {
            // Month
            formatter.dateFormat = "MMM"
            let month = formatter.string(from: date)
            
            // Day
            formatter.dateFormat = "d"
            let lowerDay = Int(formatter.string(from: date)) ?? 0
            let upperDay = lowerDay + (days - 1)
            
            return "\(lowerDay)-\(upperDay) \(month)".uppercased()
        }
    }
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
    var event: EventContext? = nil
}

struct TeamContext: Content {
    struct TeamMember: Codable {
        let name: String
        let role: String?
        let twitter: String?
        let linkedin: String?
        let slack: String?
        let imageURL: String?
    }
    
    var teamMembers: [TeamMember] = []
    var event: EventContext? = nil
}
