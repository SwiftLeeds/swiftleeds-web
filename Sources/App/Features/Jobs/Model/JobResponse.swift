import Vapor

struct JobResponse: Content {
    let id: UUID?
    let title: String
    let location: String
    let details: String
    let url: String
}
