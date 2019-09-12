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
    
    
    func fetchUserProfile(withSessionId sessionId: String, completion: @escaping ((UserProfile?, Error?) -> Void)) {
        
        let urlString = Constants.theMovieDbSecureBaseUrl + Constants.theMovieDbProfilePath + "?" + Constants.theMovieDbApiKeyParam + "&" + Constants.theMovieDbSessionKeyName + "=" + sessionId
        
        guard let url = URL(string: urlString) else {
            let msg = "invalid url: \(urlString)"
            let error = ServiceError(type: .invalidUrl, code: ServiceErrorCode.parse.rawValue, msg: msg)
            completion(nil, error)
            return
        }
        
        jsonService.doGet(url: url, completion:
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
        
        let urlString = Constants.theMovieDbSecureBaseUrl + Constants.theMovieDbAuthTokenPath + "?" + Constants.theMovieDbApiKeyParam
        
        guard let url = URL(string: urlString) else {
            let msg = "invalid url: \(urlString)"
            let error = ServiceError(type: .invalidUrl, code: ServiceErrorCode.parse.rawValue, msg: msg)
            completion(nil, error)
            return
        }
        
        jsonService.doGet(url: url, completion:
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
        
        //post
        let urlString = Constants.theMovieDbSecureBaseUrl + Constants.theMovieDbAuthTokenValidationPath + "?" + Constants.theMovieDbApiKeyParam
        
        guard let url = URL(string: urlString) else {
            let msg = "invalid url: \(urlString)"
            let error = ServiceError(type: .invalidUrl, code: ServiceErrorCode.parse.rawValue, msg: msg)
            completion(nil, error)
            return
        }
        
        var body: [String: AnyObject] = [:]
        body["username"] = username as AnyObject
        body["password"] = password as AnyObject
        body["request_token"] = authToken as AnyObject
        
        jsonService.doPost(url: url, postBody: body, completion:
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
        
        //post
        let urlString = Constants.theMovieDbSecureBaseUrl + Constants.theMovieDbNewSessionPath + "?" + Constants.theMovieDbApiKeyParam
    
        guard let url = URL(string: urlString) else {
            let msg = "invalid url: \(urlString)"
            let error = ServiceError(type: .invalidUrl, code: ServiceErrorCode.parse.rawValue, msg: msg)
            completion(nil, error)
            return
        }
        
        var postDict: [String: AnyObject] = [:]
        postDict["request_token"] = validatedAuthToken as AnyObject
        
        jsonService.doPost(url: url, postBody: postDict, completion:
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
}
