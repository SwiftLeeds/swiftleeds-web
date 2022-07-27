//
//  Transformer.swift
//  
//
//  Created by Alex Logan on 25/07/2022.
//

import Foundation
import Vapor
import Fluent

protocol Transformer {
    associatedtype Entity: Model
    associatedtype Response: Content

    static func transform(_ entity: Entity?) -> Response?
}
