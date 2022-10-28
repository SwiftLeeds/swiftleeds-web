@testable import App
import XCTVapor

final class AppTests: XCTestCase {
    func testAASA() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        
        try app.test(.GET, ".well-known/apple-app-site-association", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.headers.first(name: .contentType), "application/json") // mime type must be set
            XCTAssertLessThan(res.body.readableBytes, 128000) // Max size is 128Kb
        })
    }
}
