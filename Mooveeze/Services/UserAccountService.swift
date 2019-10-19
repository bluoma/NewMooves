//
//  UserAccountHttpClient.swift
//  Mooveeze
//
//  Created by Bill on 9/7/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation


class UserAccountService {
    
    let jsonService = JsonHttpService()
    let movieDbHttpClient: MovieDbClient = MovieDbClient()
    
    func fetchUserProfile(withSessionId sessionId: String, completion: @escaping ((UserProfile?, Error?) -> Void)) {
        
        let remoteRequest = UserAccountRequest.fetchUserProfileRequest()
        guard let urlRequest = movieDbHttpClient.buildUrlRequest(withRemoteRequest: remoteRequest) else {
            let msg = "invalid remoteRequest: \(remoteRequest)"
            let error = ServiceError(type: .invalidUrl, code: ServiceErrorCode.parse.rawValue, msg: msg)
            completion(nil, error)
            return
        }
        
        jsonService.send(urlRequest: urlRequest, completion:
        { [weak self] (data: Data?, response: HTTPURLResponse?, error: Error?) in
            guard let _ = self else { return }
            
            if error != nil {
                dlog("err: \(String(describing: error))")
                completion(nil, error)
            }
            else if let foundData = data {
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
                assert(false, "unknown error")
            }
        })
    }
    
    func fetchAuthToken(completion: @escaping ((String?, Error?) -> Void)) {
        
        let remoteRequest: UserAccountRequest = UserAccountRequest.fetchAuthTokenRequest()
        guard let urlRequest = movieDbHttpClient.buildUrlRequest(withRemoteRequest: remoteRequest) else {
            let msg = "invalid remoteRequest: \(remoteRequest)"
            let error = ServiceError(type: .invalidUrl, code: ServiceErrorCode.parse.rawValue, msg: msg)
            completion(nil, error)
            return
        }
        dlog("sending : \(urlRequest) headers: \n\(String(describing: urlRequest.allHTTPHeaderFields))")
        jsonService.send(urlRequest: urlRequest, completion:
        { [weak self] (data: Data?, response: HTTPURLResponse?, error: Error?) in
            guard let _ = self else { return }
            
            if error != nil {
                    dlog("err: \(String(describing: error))")
                    completion(nil, error)
                }
                else if let foundData = data {
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
                    assert(false, "unknown error")
                }
        })
    }
    
    //authtoken plus username and password in body (login)
    func validateAuthToken(withAuthToken authToken: String, username: String, password: String, completion: @escaping ((String?, Error?) -> Void)) {
       
        let remoteRequest: UserAccountRequest = UserAccountRequest.validateAuthTokenRequest(authToken: authToken, username: username, password: password)
        guard let urlRequest = movieDbHttpClient.buildUrlRequest(withRemoteRequest: remoteRequest) else {
            let msg = "invalid remoteRequest: \(remoteRequest)"
            let error = ServiceError(type: .invalidUrl, code: ServiceErrorCode.parse.rawValue, msg: msg)
            completion(nil, error)
            return
        }
        
        jsonService.send(urlRequest: urlRequest, completion:
        { [weak self] (data: Data?, response: HTTPURLResponse?, error: Error?) in
            guard let _ = self else { return }
            
            if error != nil {
                dlog("err: \(String(describing: error))")
                completion(nil, error)
            }
            else if let foundData = data {
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
                assert(false, "unknown error")
            }
        })
        
    }
    
    //validated request_token in body
    func createSession(withValidatedToken validatedAuthToken: String, completion: @escaping ((String?, Error?) -> Void)) {
        
        let remoteRequest = UserAccountRequest.creationSessionRequest(withValidatedAuthToken: validatedAuthToken)
        
        guard let urlRequest = movieDbHttpClient.buildUrlRequest(withRemoteRequest: remoteRequest) else {
            let msg = "invalid remoteRequest: \(remoteRequest)"
            let error = ServiceError(type: .invalidUrl, code: ServiceErrorCode.parse.rawValue, msg: msg)
            completion(nil, error)
            return
        }
        
        jsonService.send(urlRequest: urlRequest, completion:
        { [weak self] (data: Data?, response: HTTPURLResponse?, error: Error?) in
            guard let _ = self else { return }
            
            if error != nil {
                dlog("err: \(String(describing: error))")
                completion(nil, error)
            }
            else if let foundData = data {
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
                assert(false, "unknown error")
            }
        })
    }
    
    //session_id in body
    func deleteSession(_ sessionId: String, completion: @escaping ((Bool, Error?) -> Void)) {
        
        let remoteRequest = UserAccountRequest.deleteSessionRequest()
        guard let urlRequest = movieDbHttpClient.buildUrlRequest(withRemoteRequest: remoteRequest) else {
            let msg = "invalid remoteRequest: \(remoteRequest)"
            let error = ServiceError(type: .invalidUrl, code: ServiceErrorCode.parse.rawValue, msg: msg)
            completion(false, error)
            return
        }
        
        jsonService.send(urlRequest: urlRequest, completion:
        { [weak self] (data: Data?, response: HTTPURLResponse?, error: Error?) in
            guard let _ = self else { return }
            
            if error != nil {
                dlog("err: \(String(describing: error))")
                completion(false, error)
            }
            else if let foundData = data {
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
                assert(false, "unknown error")
            }
        })
    }
}
