import Vapor
import Leaf
import Foundation
import LeafMarkdown

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
}

extension Application {
    static let db = Environment.get("DATABASE_URL")!
}
