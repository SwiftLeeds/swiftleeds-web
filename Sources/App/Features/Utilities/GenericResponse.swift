import Foundation
import Vapor

struct GenericResponse<Response: Content>: Content {
    let data: Response
}
