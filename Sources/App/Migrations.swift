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

        // Activity Migrations
        app.migrations.add(ActivityMigrationV1())

        // Slots Migrations
        app.migrations.add(SlotMigrationV1())
        
        // Sponsors Migrations
        app.migrations.add(SponsorMigrationV1())

        // Session Record Migrations
        app.migrations.add(SessionRecord.migration)

        // Location migrations
        app.migrations.add(LocationCategoryMigrationV1())
        app.migrations.add(LocationMigrationV1())

        // Dual Speaker Migrations
        app.migrations.add(PresentationMigrationV2())

        // Addition of optional Slido URL
        app.migrations.add(PresentationMigrationV3())

        // Push notification tokens
        app.migrations.add(PushMigration())
        app.migrations.add(PushMigrationV2())
        
        do {
            guard var postgresConfig = PostgresConfiguration(url: Application.db) else {
                throw Abort(.internalServerError, reason: "Invalid PostgreSQL connection URL provided")
            }
            
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
