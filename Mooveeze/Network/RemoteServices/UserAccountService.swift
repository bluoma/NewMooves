//
//  UserAccountHttpClient.swift
//  Mooveeze
//
//  Created by Bill on 9/7/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation


class UserAccountService: RemoteService {
    
    func fetchUserProfile(withSessionId sessionId: String, completion: @escaping ((UserProfile?, Error?) -> Void)) {
        
        let remoteRequest = UserAccountRequest.fetchUserProfileRequest()
        remoteRequest.successBlock = { (data: Data?, headers: [AnyHashable: Any]) -> Void in
            if let foundData = data {
                do {
                    let decoder = JSONDecoder()
                    let profile: UserProfile = try decoder.decode(UserProfile.self, from: foundData)
                    dlog("profile: \(profile)")
                    completion(profile, nil)
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
    
    func fetchAuthToken(completion: @escaping ((String?, Error?) -> Void)) {
        
        let remoteRequest: UserAccountRequest = UserAccountRequest.fetchAuthTokenRequest()
        remoteRequest.successBlock = { (data: Data?, headers: [AnyHashable: Any]) -> Void in
            if let foundData = data {
                do {
                    if let authDict = try JSONSerialization.jsonObject(with: foundData, options: .mutableContainers) as? [String: AnyObject], let authToken = authDict["request_token"] as? String {
                        dlog("authDict: \(authDict)")
                        completion(authToken, nil)
                    }
                    else {
                        let serviceError = ServiceError(type: .invalidData, code: ServiceErrorCode.parse.rawValue, msg: "json data not a dictionary or no request_token")
                        completion(nil, serviceError)
                    }
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
    
    //authtoken plus username and password in body (login)
    func validateAuthToken(withAuthToken authToken: String, username: String, password: String, completion: @escaping ((String?, Error?) -> Void)) {
       
        let remoteRequest: UserAccountRequest = UserAccountRequest.validateAuthTokenRequest(authToken: authToken, username: username, password: password)
        remoteRequest.successBlock = { (data: Data?, headers: [AnyHashable: Any]) -> Void in
            if let foundData = data {
                do {
                    if let authDict = try JSONSerialization.jsonObject(with: foundData, options: .mutableContainers) as? [String: AnyObject], let authToken = authDict["request_token"] as? String {
                        dlog("authDict: \(authDict)")
                        completion(authToken, nil)
                    }
                    else {
                        let serviceError = ServiceError(type: .invalidData, code: ServiceErrorCode.parse.rawValue, msg: "json data not a dictionary or no request_token")
                        completion(nil, serviceError)                    }
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
    
    //validated request_token in body
    func createSession(withValidatedToken validatedAuthToken: String, completion: @escaping ((String?, Error?) -> Void)) {
        
        let remoteRequest = UserAccountRequest.creationSessionRequest(withValidatedAuthToken: validatedAuthToken)
        remoteRequest.successBlock = { (data: Data?, headers: [AnyHashable: Any]) -> Void in
            if let foundData = data {
                do {
                    if let authDict = try JSONSerialization.jsonObject(with: foundData, options: .mutableContainers) as? [String: AnyObject], let seshId = authDict["session_id"] as? String {
                        dlog("authDict: \(authDict)")
                        completion(seshId, nil)
                    }
                    else {
                        let serviceError = ServiceError(type: .invalidData, code: ServiceErrorCode.parse.rawValue, msg: "json data not a dictionary or no session_id")
                        completion(nil, serviceError)
                    }
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
    
    //session_id in body
    func deleteSession(_ sessionId: String, completion: @escaping ((Bool, Error?) -> Void)) {
        
        let remoteRequest = UserAccountRequest.deleteSessionRequest()
        remoteRequest.successBlock = { (data: Data?, headers: [AnyHashable: Any]) -> Void in
            if let foundData = data {
                do {
                    if let authDict = try JSONSerialization.jsonObject(with: foundData, options: .mutableContainers) as? [String: AnyObject], let success = authDict["success"] as? Bool {
                        dlog("authDict: \(authDict)")
                        completion(success, nil)
                    }
                    else {
                        let serviceError = ServiceError(type: .invalidData, code: ServiceErrorCode.parse.rawValue, msg: "json data not a dictionary or no success key")
                        completion(false, serviceError)                    }
                }
                catch {
                    let serviceError = ServiceError(error)
                    completion(false, serviceError)
                }
            }
            else {
                completion(true, nil)
            }
        }
        remoteRequest.failureBlock = { (error: Error) -> Void  in
            completion(false, error)
        }
        remoteRequest.send()
    }
    
    override var description: String {
        return UserAccountService.staticName
    }
       
    override class var staticName: String {
        return "UserAccountService"
    }
}
