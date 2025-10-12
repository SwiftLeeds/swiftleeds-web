//
//  Permissions.swift
//  swift-leeds
//
//  Created by James Sherlock on 12/10/2025.
//

import Vapor

enum Permission: String, CaseIterable {
    case eventUpdate = "event.update"
}

extension Request {
    func requireUser(hasPermission permission: Permission) throws {
        let allUserPermissions = user?.permissions.compactMap { Permission(rawValue: $0) }
        
        guard allUserPermissions?.contains(permission) == true else {
            throw Abort(.unauthorized, reason: "user does not have permission `\(permission.rawValue)`")
        }
    }
}
