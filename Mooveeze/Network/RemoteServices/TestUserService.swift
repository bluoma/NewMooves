//
//  TestUserService.swift
//  MoreClients
//
//  Created by Bill on 10/25/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

class TestUserService: RemoteService {
    
    func fetchTestUser(withId userId: Int, completion: @escaping ((TestUser?, Error?) -> Void)) {
        
        let remoteRequest = TestUserRequest.fetchTestUserRequest(withUserId: userId)
        remoteRequest.successBlock = { (data: Data?, headers: [AnyHashable: Any]) -> Void in
            if let foundData = data {
                do {
                    let decoder = JSONDecoder()
                    let testUser = try decoder.decode(TestUser.self, from: foundData)
                    completion(testUser, nil)
                }
                catch {
                    let serviceError = ServiceError(error)
                    completion(nil, serviceError)
                }
            }
            else {
                completion(nil, nil)
            }
        }
        remoteRequest.failureBlock = { (error: Error) -> Void  in
            completion(nil, error)
        }
        remoteRequest.send()
    }
    
    func fetchTestUsers(completion: @escaping (([TestUser], Error?) -> Void)) {
        
        let remoteRequest = TestUserRequest.fetchTestUsersRequest()
        remoteRequest.successBlock = { (data: Data?, headers: [AnyHashable: Any]) -> Void in
            if let foundData = data {
                do {
                    let decoder = JSONDecoder()
                    let testUsers: [TestUser] = try decoder.decode([TestUser].self, from: foundData)
                    completion(testUsers, nil)
                }
                catch {
                    let serviceError = ServiceError(error)
                    completion([], serviceError)
                }
            }
            else {
                completion([], nil)
            }
        }
        remoteRequest.failureBlock = { (error: Error) -> Void  in
            completion([], error)
        }
        remoteRequest.send()
    }
    
    var description: String {
        return TestUserService.staticName
    }
       
    class var staticName: String {
        return "TestUserService"
    }
}
