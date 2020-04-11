//
//  UserController.swift
//  App
//
//  Created by Abdulaziz AlObaili on 11/04/2020.
//

import Vapor
import Fluent

struct UserController: RouteCollection {
    
    func boot(router: Router) throws {
        let usersRouter = router.grouped("v1", "users")
        
        usersRouter.get(use: getUsers)
        usersRouter.get("find", Int.parameter, use: getUserByID)
        usersRouter.get("sorted", use: getSortedUsers)
        usersRouter.get(User.parameter, "samples", use: getSamplesForUser)
        usersRouter.post(use: postUser)
        usersRouter.put(User.parameter, use: putUser)
        usersRouter.delete(User.parameter, use: deleteUser)
    }
    
    func getUsers(_ request: Request) throws -> Future<[User]> {
        if let queryString = request.query[String.self, at: "firstName"] {
            return User.query(on: request).filter(\.firstName == queryString).all()
        }
        return User.query(on: request).all()
    }
    
    func getUserByID(_ request: Request) throws -> Future<User> {
        let userID = try request.parameters.next(Int.self)
        return User.find(userID, on: request)
            .unwrap(or: Abort(HTTPStatus.notFound))
    }
    
    func getSortedUsers(_ request: Request) throws -> Future<[User]> {
        User.query(on: request).sort(\.firstName, .ascending).all()
    }
    
    func getSamplesForUser(_ request: Request) throws -> Future<[Sample]> {
        try request.parameters.next(User.self)
            .flatMap(to: [Sample].self) { (user) in
                try user.samples.query(on: request).all()
        }
    }
    
    func postUser(_ request: Request) throws -> Future<User> {
        try request.content.decode(User.self)
            .flatMap(to: User.self) { (user) in
                user.save(on: request)
        }
    }
    
    func putUser(_ request: Request) throws -> Future<User> {
        try flatMap(to: User.self, request.parameters.next(User.self), request.content.decode(User.self)) { (user, updatedUser) in
            user.firstName = updatedUser.firstName
            user.lastName = updatedUser.lastName
            user.age = updatedUser.age
            
            return user.save(on: request)
        }
    }
    
    func deleteUser(_ request: Request) throws -> Future<HTTPStatus> {
        try request.parameters.next(User.self)
            .delete(on: request)
            .transform(to: HTTPStatus.noContent)
    }
    
    
}
