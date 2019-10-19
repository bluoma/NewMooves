//
//  HttpRequest.swift
//  Mooveeze
//
//  Created by Bill on 10/18/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

class JsonHttpRequest: RemoteRequest {
    
    let jsonService = JsonHttpService()
    
    @discardableResult override func send() -> AnyObject? {
        
        guard let client = NetworkService.shared.clientForRequest(name: String(describing: self)) else {
            let error = ServiceError(type: .invalidRequest, code: -700, msg: "No client for request \(String(describing: self))")
            self.failureBlock?(error)
            return nil
        }
        
        guard let urlRequest = client.buildUrlRequest(withRemoteRequest: self) else {
            let error = ServiceError(type: .invalidRequest, code: -800, msg: "No urlRequest from client: \(String(describing: client))")
            self.failureBlock?(error)
            return nil
        }
        
        let task: URLSessionDataTask = jsonService.send(urlRequest: urlRequest, completion:
        { [weak self] (data: Data?, response: HTTPURLResponse?, error: Error?) in
            
            guard let myself = self else { return }
            
            if let error = error {
                myself.failureBlock?(error)
            }
            else {
                var headers = response?.allHeaderFields ?? [:]
                headers["statusCode"] = response?.statusCode ?? 0
                myself.successBlock?(data, headers)
            }
            NetworkService.shared.removeTask(forRequest: myself)
        })
        
        NetworkService.shared.addTask(task, forRequest: self)
        
        return task
    }
    
}

