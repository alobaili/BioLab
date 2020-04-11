//
//  User.swift
//  App
//
//  Created by Abdulaziz AlObaili on 11/04/2020.
//

import Vapor
import FluentMySQL

final class User: Codable {
    
    var id: Int?
    var firstName: String
    var lastName: String
    var age: Int
    
    
    init(firstName: String, lastName: String, age: Int) {
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
    }
    
    
}

extension User: MySQLModel {}

extension User: Migration {}

extension User: Content {}

extension User: Parameter {}
