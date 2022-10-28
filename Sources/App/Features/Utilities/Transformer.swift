import Fluent
import Foundation
import Vapor

protocol Transformer {
    associatedtype Entity: Model
    associatedtype Response: Content

    static func transform(_ entity: Entity?) -> Response?
}
