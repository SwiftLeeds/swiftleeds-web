@testable import App
import VaporTesting
import Testing

@Suite("Application Tests")
struct AppTests {
    private func withApp(_ test: (Application) async throws -> ()) async throws {
        let app = try await Application.make(.testing)
        
        do {
            try await configure(app)
            try await test(app)
        } catch {
            try await app.asyncShutdown()
            throw error
        }
        
        try await app.asyncShutdown()
    }
    
    @Test("Ensure AASA has correct format")
    func verifyAASA() async throws {
        try await withApp { app in
            try await app.testing().test(.GET, ".well-known/apple-app-site-association", afterResponse: { res in
                #expect(res.status == .ok)
                #expect(res.headers.first(name: .contentType) == "application/json") // mime type must be set
                #expect(res.body.readableBytes < 128000) // Max size is 128Kb
            })
        }
    }
}
