import Vapor

func routes(_ app: Application) throws {
    app.get { req -> EventLoopFuture<View> in
        let cfpExpirationDate = Date(timeIntervalSince1970: 1651356000)
        return req.view.render("Home/home", HomeContext(cfpActive: Date() < cfpExpirationDate))
    }
}
