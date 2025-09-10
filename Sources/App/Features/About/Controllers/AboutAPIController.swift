import Vapor

struct AboutAPIController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: onGet)
    }

    @Sendable func onGet(request: Request) async throws -> Response {
        let aboutData = AboutResponse(
            title: "About",
            description: [
                "Founded by Adam Rush in 2019, SwiftLeeds has set out to bring a modern, inclusive conference to the north of the UK.",
                "Ran by just a handful of community volunteers, SwiftLeeds is entirely non-profit with every penny going into delivering the best experience possible.",
                "In-person conferences are the best way to meet like-minded people who enjoy building apps with Swift. You can also learn from the best people in the industry and chat about all things Swift."
            ],
            foundedYear: "2019",
            founderName: "Adam Rush",
            founderTwitter: "https://twitter.com/Adam9Rush"
        )
        
        let response = GenericResponse(
            data: aboutData
        )
        
        return try await response.encodeResponse(for: request)
    }
}
