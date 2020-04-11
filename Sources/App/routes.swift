import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        return "It works!"
    }
    
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }
    
    // MARK: Users
    
    router.get("v1", "users") { (request) -> Future<[User]> in
        if let queryString = request.query[String.self, at: "firstName"] {
            return User.query(on: request).filter(\.firstName == queryString).all()
        }
        return User.query(on: request).all()
    }
    
    router.get("v1", "users", "find", Int.parameter) { (request) -> Future<User> in
        let userID = try request.parameters.next(Int.self)
        return User.find(userID, on: request)
            .unwrap(or: Abort(HTTPStatus.notFound))
    }
    
    router.get("v1", "users", "sorted") { (request) -> Future<[User]> in
        User.query(on: request).sort(\.firstName, .ascending).all()
    }
    
    router.post("v1", "users") { (request) -> Future<User> in
        try request.content.decode(User.self)
            .flatMap(to: User.self) { (user) in
                user.save(on: request)
            }
    }
    
    router.put("v1", "users", User.parameter) { (request) -> Future<User> in
        try flatMap(to: User.self, request.parameters.next(User.self), request.content.decode(User.self)) { (user, updatedUser) in
            user.firstName = updatedUser.firstName
            user.lastName = updatedUser.lastName
            user.age = updatedUser.age
            
            return user.save(on: request)
        }
    }
    
    router.delete("v1", "users", User.parameter) { (request) -> Future<HTTPStatus> in
        try request.parameters.next(User.self)
            .delete(on: request)
            .transform(to: HTTPStatus.noContent)
    }
    
    // MARK: Samples
    
    router.post("v1", "samples") { (request) -> Future<Sample> in
        try request.content.decode(Sample.self)
            .flatMap(to: Sample.self) { (sample) in
                sample.save(on: request)
            }
    }
    
    router.get("v1", "samples", Sample.parameter, "user") { (request) -> Future<User> in
        try request.parameters.next(Sample.self)
            .flatMap(to: User.self) { (sample) in
                sample.user.get(on: request)
            }
    }
    
    router.get("v1", "users", User.parameter, "samples") { (request) -> Future<[Sample]> in
        try request.parameters.next(User.self)
            .flatMap(to: [Sample].self) { (user) in
                try user.samples.query(on: request).all()
            }
    }
}
