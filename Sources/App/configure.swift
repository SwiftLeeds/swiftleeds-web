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

    // Use Leaf
    app.views.use(.leaf)
    
    // register routes
    app.migrations.add(App.Event.Migrations())
    app.migrations.add(App.User.Migrations())
    app.migrations.add(UserToken.Migrations())
    app.migrations.add(Speaker.Migrations())
    app.migrations.add(Presentation.Migrations())
    app.migrations.add(SessionRecord.migration)
    do {
        try app.databases.use(.postgres(url: Application.db), as: .psql)
    } catch {
        app.logger.error("Failed to connect to DB with error \(error)")
    }
    try routes(app)
}

extension Application {
    static let db = Environment.get("DATABASE_URL")!
}
