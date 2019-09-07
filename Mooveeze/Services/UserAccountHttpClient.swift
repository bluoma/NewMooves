//
//  UserAccountHttpClient.swift
//  Mooveeze
//
//  Created by Bill on 9/7/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation


class UserAccountHttpClient {
    
    let jsonService = JsonHttpService()
    
    
    func fetchUserProfile(params: [String: AnyObject], completion: @escaping ((UserProfile?, NSError?) -> Void)) {
        
        guard let localSessionId = params["sessionId"] as? String else {
            let error = generateError(withCode: -400, msg: "no sessionId")
            completion(nil, error)
            return
        }
        
        let urlString = Constants.theMovieDbSecureBaseUrl + Constants.theMovieDbProfilePath + "?" + Constants.theMovieDbApiKeyParam + "&" + Constants.theMovieDbSessionKeyName + "=" + localSessionId
        
        guard let url = URL(string: urlString) else {
            let error = generateError(withCode: -400, msg: "url error: \(urlString)")
            completion(nil, error)
            return
        }
        
        jsonService.doGet(url: url, completion:
        { [weak self] (data: Data?, response: HTTPURLResponse?, error: NSError?) in
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
                    completion(nil, error as NSError)
                }
            }
            else {
                completion(nil, generateError(withCode: -404, msg: "no data or error"))
            }
        })
    }
    
    func fetchAuthToken(completion: @escaping ((String?, NSError?) -> Void)) {
        
        let urlString = Constants.theMovieDbSecureBaseUrl + Constants.theMovieDbAuthTokenPath + "?" + Constants.theMovieDbApiKeyParam
        
        guard let url = URL(string: urlString) else {
            let error = generateError(withCode: -400, msg: "url error: \(urlString)")
            completion(nil, error)
            return
        }
        
        jsonService.doGet(url: url, completion:
        { [weak self] (data: Data?, response: HTTPURLResponse?, error: NSError?) in
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
                        completion(nil, generateError(withCode: -400, msg: "no validated request token found"))
                    }
                }
                catch {
                    completion(nil, error as NSError)
                }
            }
            else {
                completion(nil, generateError(withCode: -404, msg: "no data or error"))
            }
        })
       
    }
    
    //authtoken plus username and password in body (login)
    func validateAuthToken(body: [String: AnyObject], completion: @escaping ((String?, NSError?) -> Void)) {
        
        //post
        let urlString = Constants.theMovieDbSecureBaseUrl + Constants.theMovieDbAuthTokenValidationPath + "?" + Constants.theMovieDbApiKeyParam
        
        guard let url = URL(string: urlString) else {
            let error = generateError(withCode: -400, msg: "url error: \(urlString)")
            completion(nil, error)
            return
        }
        
        jsonService.doPost(url: url, postBody: body, completion:
        { [weak self] (data: Data?, response: HTTPURLResponse?, error: NSError?) in
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
                        completion(nil, generateError(withCode: -400, msg: "no request token found"))
                    }
                }
                catch {
                    completion(nil, error as NSError)
                }
            }
            else {
                completion(nil, generateError(withCode: -404, msg: "no data or error"))
            }
        })
        
    }
    
    //validated request_token in body
    func createSession(body: [String: AnyObject], completion: @escaping ((String?, NSError?) -> Void)) {
        
        //post
        let urlString = Constants.theMovieDbSecureBaseUrl + Constants.theMovieDbNewSessionPath + "?" + Constants.theMovieDbApiKeyParam
    
        guard let url = URL(string: urlString) else {
            let error = generateError(withCode: -400, msg: "url error: \(urlString)")
            completion(nil, error)
            return
        }
        
        jsonService.doPost(url: url, postBody: body, completion:
        { [weak self] (data: Data?, response: HTTPURLResponse?, error: NSError?) in
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
                        completion(nil, generateError(withCode: -400, msg: "no session id found"))
                    }
                }
                catch {
                    completion(nil, error as NSError)
                }
            }
            else {
                completion(nil, generateError(withCode: -404, msg: "no data or error"))
            }
        })
    }
}
