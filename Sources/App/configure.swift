import Vapor
import Leaf
import Fluent
import FluentPostgresDriver
import Foundation

// configures your application
public func configure(_ app: Application) throws {
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.middleware.use(app.sessions.middleware)
    app.middleware.use(AppUser.sessionAuthenticator())
    app.sessions.use(.fluent(.psql))

    // Use Leaf
    app.views.use(.leaf)
    
    // register routes
    app.migrations.add(AppUser.Migrations())
    app.migrations.add(UserToken.Migrations())
    app.migrations.add(SessionRecord.migration)
    try app.databases.use(.postgres(url: Application.db), as: .psql)
    try routes(app)
}

extension Application {
    static let db = Environment.get("DB_URL")!
}
