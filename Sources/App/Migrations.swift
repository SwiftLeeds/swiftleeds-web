import Vapor
import Fluent
import FluentPostgresDriver

class Migrations {
    static func migrate(_ app: Application) throws {
        app.sessions.use(.fluent(.psql))
        
        // User Migrations
        app.migrations.add(UserMigrationV1())
        
        // User Token Migrations
        
        app.migrations.add(UserTokenMigrationV1())
        
        // Event Migrations
        
        app.migrations.add(EventMigrationV1())
        
        // Speaker Migrations
        
        app.migrations.add(SpeakerMigrationV1())

        // Presentation Migrations
        
        app.migrations.add(PresentationMigrationV1())

        // Session Record Migrations
        
        app.migrations.add(SessionRecord.migration)
        
        do {
            struct DatabaseError: Error {}
            
            guard var postgresConfig = PostgresConfiguration(url: Application.db) else {
                throw DatabaseError()
            }
            
            postgresConfig.tlsConfiguration = .makeClientConfiguration()
            postgresConfig.tlsConfiguration?.certificateVerification = .none
            
            app.databases.use(.postgres(configuration: postgresConfig), as: .psql)
            
            app.autoMigrate()
            try routes(app)
        } catch {
            app.logger.error("Failed to connect to DB with error \(error)")
        }
    }
}
