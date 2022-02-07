import Vapor
import Leaf

// configures your application
public func configure(_ app: Application) throws {
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // Use Leaf
    app.views.use(.leaf)
    
    // register routes
    try routes(app)
}
