//
//  Sample.swift
//  App
//
//  Created by Abdulaziz AlObaili on 11/04/2020.
//

import Vapor
import FluentMySQL

final class Sample: Codable {
    
    var id: UUID?
    var userID: User.ID
    var isProcessed: Bool
    
    
    init(userID: User.ID, isProcessed: Bool) {
        self.userID = userID
        self.isProcessed = isProcessed
    }
    
    
}

extension Sample: MySQLUUIDModel {}

extension Sample: Migration {}

extension Sample: Content {}

extension Sample: Parameter {}

extension Sample {
    
    var user: Parent<Sample, User> {
        parent(\.userID)
    }
    
    
}
