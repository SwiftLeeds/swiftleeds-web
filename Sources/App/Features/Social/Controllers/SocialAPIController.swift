import Vapor

struct SocialAPIController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: onGet)
    }

    @Sendable func onGet(request: Request) async throws -> Response {
        let socialLinks = [
            SocialLink(
                id: "twitter",
                name: "Twitter",
                url: "https://twitter.com/swift_leeds",
                icon: "bx bxl-twitter",
                displayName: "@Swift_Leeds",
                order: 1
            ),
            SocialLink(
                id: "mastodon",
                name: "Mastodon",
                url: "https://iosdev.space/@swiftleeds",
                icon: "bx bxl-mastodon",
                displayName: "@swiftleeds",
                order: 2
            ),
            SocialLink(
                id: "youtube",
                name: "YouTube",
                url: "https://www.youtube.com/channel/UCCq1K0eWKZFBCpqaC3n8V1g",
                icon: "bx bxl-youtube",
                displayName: nil,
                order: 3
            ),
            SocialLink(
                id: "slack",
                name: "Join Slack",
                url: "https://join.slack.com/t/swiftleedsworkspace/shared_invite/zt-wkmr6pif-ZDCdDeHM60jcBUy0BxHdCQ",
                icon: "bx bxl-slack",
                displayName: nil,
                order: 4
            ),
            SocialLink(
                id: "flickr",
                name: "Flickr",
                url: "https://www.flickr.com/photos/196979204@N02/albums/72177720303878744",
                icon: "bx bxl-flickr",
                displayName: nil,
                order: 5
            ),
            SocialLink(
                id: "spotify",
                name: "Spotify",
                url: "https://open.spotify.com/show/3pHsjVt54MDDHdzZce7ezl",
                icon: "bx bxl-spotify",
                displayName: nil,
                order: 6
            )
        ]
        
        let response = GenericResponse(
            data: SocialResponse(socialLinks: socialLinks)
        )
        
        return try await response.encodeResponse(for: request)
    }
}
