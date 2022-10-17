import Fluent
import Vapor
import APNS

struct PushController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let push = routes.grouped("push")
        push.post(use: create)
        push.post("testNotification", use: testNotification)
        push.post("sendNotification", use: sendNotification)
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

    private func sendNotification(req: Request) async throws -> HTTPStatus {
        struct SendNotificationRequest: Decodable {
            let message: String
            let securityCode: String
        }

        let notificationRequest = try req.content.decode(SendNotificationRequest.self)
        let secretSecurityCode = Environment.get("PUSH_SECURITY_CODE")

        guard notificationRequest.securityCode == secretSecurityCode else { throw Abort(.forbidden) }

        let tokens = try await Token.query(on: req.db).all()
        let alert = APNSwiftAlert(title: "SwiftLeeds", body: notificationRequest.message)

        tokens.forEach { token in
            _ = req.apns.send(alert, to: token.token)
        }

        return .noContent
    }
}
