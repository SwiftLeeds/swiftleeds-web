import Fluent
import FluentPostgresDriver
import Vapor

class Migrations {
    static func migrate(_ app: Application) async throws {
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

        // Add Job table
        app.migrations.add(JobMigrationV1())

        // Add Video URL to Presentations table
        app.migrations.add(PresentationMigrationV5())
        
        app.migrations.add(AddDropInGroupsMigration()) // Drop-ins v2 (Group Sessions)
        app.migrations.add(EventMigrationV3()) // Adds tito ID
        app.migrations.add(UseArrayDropInOwnerMigration()) // Use arrays for slot owners
        app.migrations.add(AddDurationToDropInMigration()) // Add duration to slot
        app.migrations.add(AddDropInTBAMigration()) // Hide drop-in by default
        app.migrations.add(EventMigrationV4()) // Add sessionize_key and show_schedule

        do {
            guard let url = Environment.get("DATABASE_URL") else {
                throw Abort(.internalServerError, reason: "Missing 'DATABASE_URL' environment variable")
            }
            
            var postgresConfig = try SQLPostgresConfiguration(url: url)
            var configuration = TLSConfiguration.makeClientConfiguration()
            configuration.certificateVerification = .none
            
            if app.environment.isRelease {
                // Based on recommended approach from https://devcenter.heroku.com/articles/connecting-heroku-postgres
                postgresConfig.coreConfiguration.tls = try .require(.init(configuration: configuration))
            } else {
                postgresConfig.coreConfiguration.tls = try .prefer(.init(configuration: configuration))
            }
            
            app.databases.use(.postgres(configuration: postgresConfig), as: .psql)
        } catch {
            app.logger.error("Failed to connect to DB with error \(error)")
        }
        
        do {
            if app.environment != .testing {
                try await app.autoMigrate()
            }
        } catch {
            app.logger.error("Failed to migrate DB with error \(error)")
        }
    }
}
