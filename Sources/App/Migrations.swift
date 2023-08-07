import Fluent
import FluentPostgresDriver
import Vapor

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
        
        // Presentation: remove unused image field
        app.migrations.add(PresentationMigrationV4())
        
        // Drop-in Sessions
        app.migrations.add(AddDropInSessionMigration())
        app.migrations.add(AddDropInSessionSlotsMigration())
        app.migrations.add(EventMigrationV2())
        
        // Full dates in Slots
        app.migrations.add(SlotMigrationV2())

        // Add subtitle field to Sponsors table
        app.migrations.add(SponsorMigrationV2())

        // Add Last updated table and initial dates (for use with ETags)
        app.migrations.add(LastUpdatedMigrationV1())

        // Add default entries into Last Update table
        app.migrations.add(LastUpdatedMigrationV2())

        do {
            guard let url = Environment.get("DATABASE_URL") else {
                throw Abort(.internalServerError, reason: "Missing 'DATABASE_URL' environment variable")
            }

            guard var postgresConfig = PostgresConfiguration(url: url) else {
                throw Abort(.internalServerError, reason: "Invalid PostgreSQL connection URL provided")
            }
            
            if app.environment.isRelease {
                // Based on recommended approach from https://devcenter.heroku.com/articles/connecting-heroku-postgres
                postgresConfig.tlsConfiguration = .makeClientConfiguration()
            }
            
            postgresConfig.tlsConfiguration?.certificateVerification = .none
            
            app.databases.use(.postgres(configuration: postgresConfig), as: .psql)
        } catch {
            app.logger.error("Failed to connect to DB with error \(error)")
        }
        
        do {
            if app.environment != .testing {
                try app.autoMigrate().wait()
            }
        } catch {
            app.logger.error("Failed to migrate DB with error \(error)")
        }
    }
}
