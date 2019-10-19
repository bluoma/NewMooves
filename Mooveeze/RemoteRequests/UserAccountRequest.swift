//
//  File.swift
//  Mooveeze
//
//  Created by Bill on 10/17/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

class UserAccountRequest: JsonHttpRequest {
    
    override init() {
        super.init()
        super.version = "/3"
        super.resourcePath = "/authentication"
    }
    
    class func fetchUserProfileRequest() -> UserAccountRequest {
    
        let request = UserAccountRequest()
        request.method = HTTPMethod.get.rawValue
        request.resourcePath = "/account"
        request.requiresSession = true
        
        return request
    }
    
    class func fetchAuthTokenRequest() -> UserAccountRequest {
    
        let request = UserAccountRequest()
        request.method = HTTPMethod.get.rawValue
        request.appendPath("token/new")
        
        return request
    }
    
    class func validateAuthTokenRequest(authToken: String, username: String, password: String) -> UserAccountRequest {
    
        let request = UserAccountRequest()
        request.method = HTTPMethod.post.rawValue
        request.appendPath("token/validate_with_login")
        request.contentType = "application/json"
        request.contentBody["request_token"] = authToken
        request.contentBody["username"] = username
        request.contentBody["password"] = password

        return request
    }
    
    class func creationSessionRequest(withValidatedAuthToken validatedAuthToken: String) -> UserAccountRequest {
        
        let request = UserAccountRequest()
        request.method = HTTPMethod.post.rawValue
        request.appendPath("session/new")
        request.contentType = "application/json"
        request.contentBody["request_token"] = validatedAuthToken
               
        return request
    }
    
    class func deleteSessionRequest() -> UserAccountRequest {
       
        let request = UserAccountRequest()
        request.method = HTTPMethod.delete.rawValue
        request.appendPath("session")
        request.contentType = "application/json"
        request.contentBody["session_id"] = Constants.sessionId
        
        return request
   }
    
    override var description: String {
        return UserAccountRequest.staticName
    }
    
    class var staticName: String {
        return "UserAccountRequest"
    }
}
