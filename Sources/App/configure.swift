import APNS
import Leaf
import LeafMarkdown
import Vapor

public func configure(_ app: Application) throws {
    // Sessions
    app.sessions.use(.fluent(.psql))
    
    // Middleware
    app.middleware.use(AppleAppSiteAssociationMiddleware())
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.middleware.use(app.sessions.middleware)
    app.middleware.use(User.sessionAuthenticator())
    
    // Compression
    app.http.server.configuration.responseCompression = .enabled

    // Leaf
    app.leaf.tags["copyright"] = CopyrightTag()
    app.leaf.tags["dateFormat"] = NowTag()
    app.leaf.tags["sessionEnd"] = SessionEndTag()
    app.leaf.tags["markdown"] = Markdown()
    app.leaf.tags["awsImage"] = AwsImageTag()
    app.leaf.tags["safeCount"] = SafeCountTag()
    app.leaf.tags["hash"] = HashTag()
    app.views.use(.leaf)

    // Migrations
    try Migrations.migrate(app)

    // Model middleware
    app.databases.middleware.use(SponsorMiddleware(), on: .psql)

    // Routes
    app.routes.defaultMaxBodySize = "10mb"
    try routes(app)

    // APNS
    if
        let encodedKey = Environment.get("P8_CERTIFICATE"),
        encodedKey.isEmpty == false,
        let data = Data(base64Encoded: encodedKey),
        let p8Key = String(data: data, encoding: .utf8)
    {
        let apnsEnvironment: APNSwiftConfiguration.Environment = app.environment == .production ? .production : .sandbox
        let auth: APNSwiftConfiguration.AuthenticationMethod = try .jwt(key: .private(pem: p8Key), keyIdentifier: "K4D2BJ235Y", teamIdentifier: "K33K6V7FBA")
        app.apns.configuration = .init(authenticationMethod: auth, topic: "uk.co.swiftleeds.SwiftLeeds", environment: apnsEnvironment)
    }
}
