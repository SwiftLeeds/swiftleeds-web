import Vapor

struct TalkRouteController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let route = routes.grouped(User.sessionAuthenticator())
        route.get("talk", ":talk", use: talk)
    }
    
    @Sendable private func talk(req: Request) async throws -> View {
        let context = TalkContext(
            title: "ICYMI: Enums Are...",
            description: """
            2 facts about me: I am obsessed with enums, and I am a professional drummer and percussionist 🎵

            For this talk, I'd like to marry these great loves by

            1. sharing my curiosity about enums with the SwiftLeeds community
            2. leveraging my musical skills as the backdrop for a sample app called PocketPerc: Beat Generator

            In the app, a user would be able to toggle on any number of instrument samples to build a unique groove all their own, with samples largely recorded by me 🥁

            To build up to the beat part (obviously the Grand Finale), I’d like to showcase enums in all their glory, aka possibly/hopefully using them way too much and inspiring some wild ideas about what they can do 🤗 The static data we would need is a perfect opportunity to eclipse structs and classes as the go-to data types, and instead rely heavily on enums to build views and stay categorized! To make it extra fun, I plan to limit myself as much as possible to only that data type, see what boundaries we bump up against, and discuss where and why we might want to pivot to another structure for production.

            Here’s a non-exhaustive list of the power moves I’ve been exploring:

            Protocol conformance CaseIterable, Equatable and Comparable conformances Associated values (with and without default values) Pattern matching Screen management Static properties Computed properties Interaction with ObservableObjects Custom raw types
            """.replacingOccurrences(of: "\n", with: "<br />"),
            author: "Jessie Linden",
            location: "Leeds Playhouse",
            date: Date(timeIntervalSince1970: 1696932000),
            slidesReference: "c59200e0b734457f9685964c3f3e7c58",
            videoReference: "J4s3mraKcag",
            imageLink: "https://live.staticflickr.com/65535/53300388151_07124551b2_c_d.jpg",
            resources: [
                "https://github.com/jessielinden/ICYMI-EnumsAreTheSh-t"
            ]
        )
        
        // We can detect the current playback position of the YouTube video (https://stackoverflow.com/a/39160557)
        // We would want to sync this with the SpeakerDeck iframe (and a transcript) using some form of JavaScript implementation and mapping
        
        return try await req.view.render("Talk/index", context)
    }
}

struct TalkContext: Content {
    let title: String
    let description: String
    let author: String
    let location: String
    let date: Date
    
    let slidesReference: String
    let videoReference: String
    let imageLink: String
    
    let resources: [String]
}
