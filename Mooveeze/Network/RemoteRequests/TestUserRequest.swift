//
//  TestUserRequest.swift
//  MoreClients
//
//  Created by Bill on 10/24/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

class TestUserRequest: JsonWsRequest {
    
    override init() {
        super.init()
        super.version = "/api/v1"
        super.resourcePath = "/user"
    }
    
    
    class func fetchTestUserRequest(withUserId userId: Int) -> TestUserRequest {
    
        let request = TestUserRequest()
        request.method = "wstext"
        request.requiresSession = false
        request.appendPath(String(userId))
        request.params["messageId"] = request.requestId

        return request
    }
    
    class func fetchTestUsersRequest() -> TestUserRequest {
       
        let request = TestUserRequest()
        request.method = "wstext"
        request.requiresSession = false
        request.resourcePath = "/users"
        request.params["messageId"] = request.requestId

        return request
    }
    
    override var description: String {
        return TestUserRequest.staticName
    }
    
    override class var staticName: String {
        return "TestUserRequest"
    }
    
    
}
