//
//  HomeController.swift
//  App
//
//  Created by Abdulaziz AlObaili on 12/04/2020.
//

import Vapor
import Leaf

struct HomeController: RouteCollection {
    
    func boot(router: Router) throws {
        router.get(use: home)
        router.get("users", User.parameter, use: samples)
        router.get("users", use: users)
        router.get("users", "create", use: userCreate)
        
        router.post(User.self, at: "users", use: users)
        router.post("users", User.parameter, "samples", use: sampleCreate)
    }
    
    func home(_ request: Request) throws -> Future<View> {
        let homeContext = HomeContext(title: "BioLab")
        return try request.view().render("home", homeContext)
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
    
    func users(_ request: Request) throws -> Future<View> {
        User.query(on: request)
            .all()
            .flatMap(to: View.self) { (users) in
                let users = users.isEmpty ? nil : users
                let userContext = UserContext(title: "Users", users: users)
                return try request.view().render("user", userContext)
            }
    }
    
    func userCreate(_ request: Request) throws -> Future<View> {
        try request.view().render("userCreate")
    }
    
    func users(_ request: Request, user: User) throws -> Future<Response> {
        user.save(on: request)
            .map(to: Response.self) { (user) in
                guard let userID = user.id else {
                    throw Abort(.internalServerError)
                }
                
                return request.redirect(to: "/users/\(userID)")
            }
    }
    
    func sampleCreate(_ request: Request) throws -> Future<Response> {
        try request.parameters.next(User.self)
            .flatMap(to: Response.self) { (user) in
                guard let userID = user.id else {
                    throw Abort(.internalServerError)
                }
                
                let sample = Sample(userID: userID, isProcessed: false)
                
                return sample.save(on: request)
                    .map(to: Response.self) { (sample) in
                        guard sample.id != nil else {
                            throw Abort(.internalServerError)
                        }
                        
                        return request.redirect(to: "/users/\(userID)")
                }
            }
    }
    
}

struct HomeContext: Encodable {
    
    var title: String
    
    
}

struct SampleContext: Encodable {
    
    var title: String
    var samples: [Sample]
    var user: User
    
    
}

struct UserContext: Encodable {
    
    var title: String
    var users: [User]?
    
    
}
