import Vapor

struct TeamAPIController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.get(use: getTeam)
    }
    
    @Sendable func getTeam(req: Request) async throws -> TeamResponse {
        let teamMembers = [
            TeamMember(
                name: "Adam Rush",
                role: "Founder and Host",
                twitter: "https://twitter.com/Adam9Rush",
                linkedin: "https://www.linkedin.com/in/swiftlyrush/",
                slack: "https://swiftleedsworkspace.slack.com/archives/D05RK6AAV29",
                imageURL: "/img/team/rush.jpg"
            ),
            TeamMember(
                name: "James Sherlock",
                role: "Production Team Lead",
                twitter: "https://twitter.com/JamesSherlouk",
                linkedin: "https://www.linkedin.com/in/jamessherlockdeveloper/",
                slack: "https://swiftleedsworkspace.slack.com/archives/D05RK6AAV29",
                imageURL: "/img/team/sherlock.jpg"
            ),
            TeamMember(
                name: "Matthew Gallagher",
                role: "Registration and Mobile App",
                twitter: "https://twitter.com/pdamonkey",
                linkedin: "https://www.linkedin.com/in/pdamonkey/",
                slack: "https://swiftleedsworkspace.slack.com/archives/D030PN528UA",
                imageURL: "/img/team/matt.jpg"
            ),
            TeamMember(
                name: "Adam Oxley",
                role: nil,
                twitter: "https://twitter.com/admoxly",
                linkedin: "https://www.linkedin.com/in/adam-oxley-41183a82/",
                slack: "https://swiftleedsworkspace.slack.com/team/U02DRL7KUCS",
                imageURL: "/img/team/oxley.jpg"
            ),
            TeamMember(
                name: "Noam Efergan",
                role: "Camera Operator and Social Media",
                twitter: "https://twitter.com/No_Wham",
                linkedin: "https://www.linkedin.com/in/noamefergan/",
                slack: "https://swiftleedsworkspace.slack.com/archives/D05RK6AAV29",
                imageURL: "/img/team/noam.jpg"
            ),
            TeamMember(
                name: "Kannan Prasad",
                role: nil,
                twitter: nil,
                linkedin: "https://www.linkedin.com/in/kannanprasad/",
                slack: "https://swiftleedsworkspace.slack.com/archives/D0477TRS28G",
                imageURL: "/img/team/kannan.jpg"
            ),
            TeamMember(
                name: "Muralidharan Kathiresan",
                role: nil,
                twitter: "https://twitter.com/Muralidharan_K",
                linkedin: "https://www.linkedin.com/in/muralidharankathiresan/",
                slack: "https://swiftleedsworkspace.slack.com/archives/D05RK6AAV29",
                imageURL: "/img/team/mural.jpg"
            ),
            TeamMember(
                name: "Preeti Thombare",
                role: nil,
                twitter: nil,
                linkedin: nil,
                slack: "https://swiftleedsworkspace.slack.com/archives/D05RK6AAV29",
                imageURL: "/img/team/preeti.jpg"
            ),
            TeamMember(
                name: "Paul Willis",
                role: nil,
                twitter: nil,
                linkedin: "https://www.linkedin.com/in/paulrobertwillis/",
                slack: "https://swiftleedsworkspace.slack.com/archives/D05RK6AAV29",
                imageURL: "/img/team/paul.jpg"
            ),
            TeamMember(
                name: "Joe Williams",
                role: "Camera Operator",
                twitter: "https://twitter.com/joedub_dev",
                linkedin: "https://www.linkedin.com/in/joe-williams-1676b871/",
                slack: "https://swiftleedsworkspace.slack.com/archives/C05N7JZE2NP",
                imageURL: "/img/team/joe.jpg"
            ),
        ]
        
        // Shuffle the team members to avoid bias, just like the web page does
        return TeamResponse(teamMembers: teamMembers.shuffled())
    }
}
