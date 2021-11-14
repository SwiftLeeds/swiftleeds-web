import Vapor
import Leaf
import Fluent
import FluentPostgresDriver
import Foundation

// configures your application
public func configure(_ app: Application) throws {
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // Use Leaf
    app.views.use(.leaf)
    
    // register routes
    app.migrations.add(AppUser.Migrations())
    app.migrations.add(UserToken.Migrations())
    try app.databases.use(.postgres(url: Application.db), as: .psql)
    try routes(app)
}

extension Application {
    static let db = Environment.get("DB_URL")!
}
