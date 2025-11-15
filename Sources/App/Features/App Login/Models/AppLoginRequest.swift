import Vapor

struct AppLoginRequest: Content {
    let event: UUID?
    let email: String
    let ticket: String
}
