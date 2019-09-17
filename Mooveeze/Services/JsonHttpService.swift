//
//  JsonHttpService.swift
//  Mooveeze
//
//  Created by Bill on 10/3/16.
//  Copyright © 2016 Bill Luoma. All rights reserved.
//

import Foundation

typealias JsonHttpServiceCompletionHandler = (Data?, HTTPURLResponse?, Error?) -> Void

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

class JsonHttpService {
    
    var session: URLSession!
    
    init() {
        let urlconfig = URLSessionConfiguration.default
        urlconfig.timeoutIntervalForRequest = 12
        urlconfig.timeoutIntervalForResource = 12
        urlconfig.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        self.session = URLSession(configuration: urlconfig, delegate: nil, delegateQueue: nil)
    }
    
    func doGet(
        url: URL,
        completion: @escaping JsonHttpServiceCompletionHandler) {
    
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        //request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = send(request: request, completion: completion)
        task.resume()
    }
    
    func doPost(
        url: URL,
        postBody: [String: AnyObject],
        completion: @escaping JsonHttpServiceCompletionHandler) {
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let data = try JSONSerialization.data(withJSONObject: postBody, options: .prettyPrinted)
            request.httpBody = data
            let task = send(request: request, completion: completion)
            task.resume()
        }
        catch {
            dlog(String(describing: error))
            let serviceError = ServiceError(type: .invalidRequest, code: ServiceErrorCode.parse.rawValue, msg: error.localizedDescription)
            completion(nil, nil, serviceError)
        }
    }
    
    //expects json dictionary as a response
    fileprivate func send(request: URLRequest, completion: @escaping JsonHttpServiceCompletionHandler) -> URLSessionDataTask {
        
        let dataTask = session.dataTask(with: request, completionHandler:
        { [weak self] (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            guard let myself = self else { return }
            
            guard let localResp = response as? HTTPURLResponse else {
                let error = ServiceError(type: .invalidResponse, code: ServiceErrorCode.notFound.rawValue, msg: "unknown response type")
                myself.returnToMain(nil, nil, error, completion)
                return
            }
            
            let contentType = localResp.allHeaderFields["Content-Type"] as? String ?? ""
            let statusCode = localResp.statusCode
            dlog("responseUrl: \(String(describing: localResp.url))")
            dlog("responseCode: \(statusCode)")
            dlog("contentType: \(contentType)")
            
            if let foundError = error {
                dlog("error: \(foundError)")
                myself.returnToMain(nil, nil, ServiceError(foundError), completion)
            }
            else if statusCode >= 400 && statusCode <= 600 {
                var msg = HTTPURLResponse.localizedString(forStatusCode: statusCode)
                //maybe it's a nice server
                if let foundData = data, let errStr = String(data: foundData, encoding: .utf8) {
                    msg = errStr
                }
                let error = ServiceError(type: .httpServer, code: statusCode, msg: msg)
                myself.returnToMain(nil, nil, error, completion)
            }
            else if let foundData = data {
                if (contentType.contains("json")) { //success
                    myself.returnToMain(foundData, localResp, nil, completion)
                }
                else {
                    let msg = "contentType is not json: \(contentType)"
                    dlog(msg)
                    let error = ServiceError(type: .invalidData, code: ServiceErrorCode.parse.rawValue, msg: msg)
                    myself.returnToMain(nil, nil, error, completion)
                }
            }
            else {
                let msg = "unknown error"
                dlog(msg)
                let error = ServiceError(type: .unknown, code: ServiceErrorCode.unknown.rawValue, msg: msg)
                myself.returnToMain(nil, nil, error, completion)
            }
        })
        
        return dataTask
    }
    
    fileprivate func returnToMain(_ data: Data?, _ resp: HTTPURLResponse?, _ error: Error?, _ completion: @escaping JsonHttpServiceCompletionHandler) {
        DispatchQueue.main.async {
            completion(data, resp, error)
        }
    }
}
