import Fluent
import Vapor
import APNS

struct PushController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let push = routes.grouped("push")
        push.post(use: create)
        push.post("testNotification", use: testNotification)
    }

    private func create(req: Request) async throws -> Token {
        let token = try req.content.decode(Token.self)

        // Either store or update the token value
        if let storedToken = try await Token.query(on: req.db)
            .filter(\.$token == token.token)
            .first() {
            storedToken.debug = token.debug
            try await storedToken.save(on: req.db)
        } else {
            try await token.save(on: req.db)
        }

        return token
    }

    private func testNotification(req: Request) async throws -> HTTPStatus {
        struct TestNotificationRequest: Decodable {
            let tokenID: String
        }

        let tokenID = try req.content.decode(TestNotificationRequest.self).tokenID

        guard
            let token = try await Token.query(on: req.db)
                .filter(\.$token == tokenID)
                .first()
        else { return .notFound }

        let alert = APNSwiftAlert(title: "SwiftLeeds Rocks!", body: "Push is working 🚀")
        _ = req.apns.send(alert, to: token.token)

        return .noContent
    }
}
