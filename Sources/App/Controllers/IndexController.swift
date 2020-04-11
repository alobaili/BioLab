//
//  IndexController.swift
//  App
//
//  Created by Abdulaziz AlObaili on 12/04/2020.
//

import Vapor
import Leaf

struct IndexController: RouteCollection {
    
    func boot(router: Router) throws {
        router.get(use: index)
        router.get("users", User.parameter, use: samples)
    }
    
    func index(_ request: Request) throws -> Future<View> {
        User.query(on: request)
            .all()
            .flatMap(to: View.self) { (users) in
                let users = users.isEmpty ? nil : users
                let indexContext = IndexContext(title: "BioLab Demo", users: users)
                return try request.view().render("index", indexContext)
            }
    }
    
    func samples(_ request: Request) throws -> Future<View> {
        try request.parameters.next(User.self)
            .flatMap(to: View.self) { (user) in
                try user.samples.query(on: request).all()
                    .flatMap(to: View.self) { (samples) in
                        let sampleContext = SampleContext(title: "Samples", samples: samples, user: user)
                        return try request.view().render("sample", sampleContext)
                    }
            }
    }
    
}

struct IndexContext: Encodable {
    
    var title: String
    var users: [User]?
    
    
}

struct SampleContext: Encodable {
    
    var title: String
    var samples: [Sample]
    var user: User
}
