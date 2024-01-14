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
    
    func testPhaseDateCalculation() {
        do { // 2014 (Unannounced)
            let event = Event(id: nil, name: "SwiftLeeds 2014", date: Date(timeIntervalSince1970: 1412899200), location: "", isCurrent: false)
            XCTAssertEqual(HomeRouteController().buildConferenceDateString(for: event), nil)
        }
        
        do { // 2021 (1 day event)
            let event = Event(id: nil, name: "SwiftLeeds 2021", date: Date(timeIntervalSince1970: 1633737600), location: "", isCurrent: false)
            XCTAssertEqual(HomeRouteController().buildConferenceDateString(for: event), "9 OCT")
        }
        
        do { // 2023 (2 day event)
            let event = Event(id: nil, name: "SwiftLeeds 2023", date: Date(timeIntervalSince1970: 1696809600), location: "", isCurrent: false)
            XCTAssertEqual(HomeRouteController().buildConferenceDateString(for: event), "9-10 OCT")
        }
    }
}
