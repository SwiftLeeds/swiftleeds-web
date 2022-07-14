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

        // Slots
        app.migrations.add(SlotMigrationV1())

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
            
        } catch {
            app.logger.error("Failed to connect to DB with error \(error)")
        }
        do {
            try app.autoMigrate().wait()
        } catch {
            app.logger.error("Failed to migrate DB with error \(error)")
        }
    }
}
