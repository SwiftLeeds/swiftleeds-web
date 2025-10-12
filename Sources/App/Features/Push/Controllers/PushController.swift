import APNSCore
import VaporAPNS
import Fluent
import Vapor

struct PushController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let push = routes.grouped("push")
        push.post(use: create)
        push.post("testNotification", use: testNotification)
        push.post("sendNotification", use: sendNotification)
    }

    @Sendable private func create(req: Request) async throws -> Token {
        let token = try req.content.decode(Token.self)

        // Either store or update the token value
        if let storedToken = try await Token.query(on: req.db)
            .filter(\.$token == token.token)
            .first()
        {
            storedToken.debug = token.debug
            try await storedToken.save(on: req.db)
        } else {
            try await token.save(on: req.db)
        }

        return token
    }

    @Sendable private func testNotification(req: Request) async throws -> HTTPStatus {
        struct TestNotificationRequest: Decodable {
            let tokenID: String
        }

        let tokenID = try req.content.decode(TestNotificationRequest.self).tokenID

        guard
            let token = try await Token.query(on: req.db)
            .filter(\.$token == tokenID)
            .first()
        else {
            return .notFound
        }

        let notification = APNSAlertNotification(
            alert: APNSAlertNotificationContent(title: .raw("SwiftLeeds Rocks!"), body: .raw("Push is working 🚀")),
            expiration: .none,
            priority: .immediately,
            topic: "uk.co.swiftleeds.SwiftLeeds"
        )
        
        try await req.apnsClient.sendAlertNotification(notification, deviceToken: token.token)

        return .noContent
    }

    @Sendable private func sendNotification(req: Request) async throws -> HTTPStatus {
        struct SendNotificationRequest: Decodable {
            let message: String
            let securityCode: String
        }

        let notificationRequest = try req.content.decode(SendNotificationRequest.self)
        let secretSecurityCode = Environment.get("PUSH_SECURITY_CODE")

        guard notificationRequest.securityCode == secretSecurityCode else {
            throw Abort(.forbidden)
        }

        let tokens = try await Token.query(on: req.db).all()

        let notification = APNSAlertNotification(
            alert: APNSAlertNotificationContent(title: .raw("SwiftLeeds"), body: .raw(notificationRequest.message)),
            expiration: .none,
            priority: .immediately,
            topic: "uk.co.swiftleeds.SwiftLeeds"
        )
        
        for token in tokens {
            try await req.apnsClient.sendAlertNotification(notification, deviceToken: token.token)
        }

        return .noContent
    }
}

extension Request {
    var apnsClient: APNSGenericClient {
        get async {
            switch application.environment {
            case .production: return await apns.client(.production)
            default: return await apns.client(.development)
            }
        }
    }
}
