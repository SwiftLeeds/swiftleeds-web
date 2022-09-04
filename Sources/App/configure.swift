import Vapor
import Leaf
import LeafMarkdown
import APNS

// configures your application
public func configure(_ app: Application) throws {
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.middleware.use(app.sessions.middleware)
    app.middleware.use(User.sessionAuthenticator())
    app.routes.defaultMaxBodySize = "10mb"
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.leaf.tags["dateFormat"] = NowTag()
    app.leaf.tags["markdown"] = Markdown()

    // Use Leaf
    app.views.use(.leaf)

    try Migrations.migrate(app)
    try routes(app)

    // APNS
    if
        let ecodedKey = Environment.get("P8_CERTIFICATE"),
        let data = Data(base64Encoded: ecodedKey),
        let p8Key = String(data: data, encoding: .utf8)
    {
        let apnsEnvironment: APNSwiftConfiguration.Environment = app.environment == .production ? .production : .sandbox
        let auth: APNSwiftConfiguration.AuthenticationMethod = try .jwt(key: .private(pem: p8Key), keyIdentifier: "K4D2BJ235Y", teamIdentifier: "K33K6V7FBA")
        app.apns.configuration = .init(authenticationMethod: auth, topic: "uk.co.swiftleeds.SwiftLeeds", environment: apnsEnvironment)
    }
}

extension Application {
    static let db = Environment.get("DATABASE_URL")!
}
