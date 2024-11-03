import Vapor

struct EngageRouteController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.webSocket("engage") { req, ws in
            ws.pingInterval = .seconds(50)
            
            ws.onBinary { ws, message in
                ws.send("received")
            }
            
            ws.onText { ws, message in
                ws.send("received")
            }
        }
    }
}
