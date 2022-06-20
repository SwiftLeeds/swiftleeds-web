import Vapor
import Leaf
import Fluent
import FluentPostgresDriver
import Foundation

// configures your application
public func configure(_ app: Application) throws {
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.middleware.use(app.sessions.middleware)
    app.middleware.use(User.sessionAuthenticator())
    app.routes.defaultMaxBodySize = "10mb"
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.sessions.use(.fluent(.psql))
    app.leaf.tags["dateFormat"] = NowTag()

    // Use Leaf
    app.views.use(.leaf)
    
    app.migrations.add(App.User.Migrations())
    app.migrations.add(UserToken.Migrations())
    app.migrations.add(App.Event.Migrations())
    app.migrations.add(Speaker.Migrations())
    app.migrations.add(Presentation.Migrations())
    app.migrations.add(SessionRecord.migration)
    
    try? app.autoMigrate()

    do {
        struct DatabaseError: Error { }
        guard var postgresConfig = PostgresConfiguration(url: Application.db) else {
            throw DatabaseError()
        }
//        postgresConfig.tlsConfiguration = .makeClientConfiguration()
//        postgresConfig.tlsConfiguration?.certificateVerification = .none
        app.databases.use(.postgres(configuration: postgresConfig), as: .psql)
    } catch {
        app.logger.error("Failed to connect to DB with error \(error)")
    }
    try routes(app)
}

extension Application {
    static let db = Environment.get("DATABASE_URL")!
}
