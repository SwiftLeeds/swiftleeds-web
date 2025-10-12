import APNS
import Leaf
import Vapor

public func configure(_ app: Application) async throws {
    // Sessions
    // https://firebase.google.com/docs/hosting/manage-cache#using_cookies
    app.sessions.configuration.cookieName = "__session"
    app.sessions.use(.fluent(.psql))
    
    // Content Encoding
    ContentConfiguration.global.use(encoder: JSONEncoder.custom(dates: .iso8601, format: .sortedKeys), for: .json)
    
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
    app.leaf.tags["markdown"] = MarkdownTag()
    app.leaf.tags["awsImage"] = AwsImageTag()
    app.leaf.tags["safeCount"] = SafeCountTag()
    app.leaf.tags["hash"] = HashTag()
    app.leaf.tags["dateFix"] = DateFixTag()
    app.leaf.tags["first"] = FirstTag()
    app.leaf.tags["cast"] = CastTag()
    app.leaf.tags["staticLoop"] = StaticLoopTag()
    app.views.use(.leaf)
    
    #if DEBUG
    app.leaf.cache.isEnabled = false
    #endif

    // Setup database and define migrations
    try await Migrations.migrate(app)

    // Check that the database has been setup
    if app.databases.ids().isEmpty == false {
        // Model middleware
        app.databases.middleware.use(SponsorMiddleware(), on: .psql)
    }

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
