//
//  SampleController.swift
//  App
//
//  Created by Abdulaziz AlObaili on 11/04/2020.
//

import Vapor
import Fluent

struct SampleController: RouteCollection {
    
    func boot(router: Router) throws {
        let samplesRouter = router.grouped("v1", "samples")
        
        samplesRouter.post(use: postSample)
        samplesRouter.get(Sample.parameter, "user", use: getUserForSample)
    }
    
    func postSample(_ request: Request) throws -> Future<Sample> {
        try request.content.decode(Sample.self)
            .flatMap(to: Sample.self) { (sample) in
                sample.save(on: request)
        }
    }
    
    func getUserForSample(_ request: Request) throws -> Future<User> {
        try request.parameters.next(Sample.self)
            .flatMap(to: User.self) { (sample) in
                sample.user.get(on: request)
        }
    }
    
    
}
