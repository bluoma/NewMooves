//
//  JsonHttpService.swift
//  Mooveeze
//
//  Created by Bill on 10/3/16.
//  Copyright © 2016 Bill Luoma. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}


class JsonHttpTransport: RemoteTransport, CustomStringConvertible {
    
    var session: URLSession
    
    var connectBlock: (() -> Void)?
    var disconnectBlock: ((Error?) -> Void)?
    
    init() {
        let urlconfig = URLSessionConfiguration.default
        urlconfig.timeoutIntervalForRequest = 12
        urlconfig.timeoutIntervalForResource = 12
        urlconfig.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        session = URLSession(configuration: urlconfig, delegate: nil, delegateQueue: nil)
    }
    
    func connect() {
    }
    
    func doGet(
        url: URL,
        completion: @escaping RemoteTransportCompletionHandler) {
    
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        //request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        send(urlRequest: request, completion: completion)
    }
    
    func doPost(
        url: URL,
        postBody: [String: AnyObject],
        completion: @escaping RemoteTransportCompletionHandler) {
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let data = try JSONSerialization.data(withJSONObject: postBody, options: [])
            request.httpBody = data
            send(urlRequest: request, completion: completion)
        }
        catch {
            dlog(String(describing: error))
            let serviceError = ServiceError(type: .invalidRequest, code: ServiceErrorCode.parse.rawValue, msg: error.localizedDescription)
            completion(nil, [:], serviceError)
        }
    }
    
    func doDelete(
        url: URL,
        deleteBody: [String: AnyObject],
        completion: @escaping RemoteTransportCompletionHandler) {
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.delete.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let data = try JSONSerialization.data(withJSONObject: deleteBody, options: [])
            request.httpBody = data
            send(urlRequest: request, completion: completion)
        }
        catch {
            dlog(String(describing: error))
            let serviceError = ServiceError(type: .invalidRequest, code: ServiceErrorCode.parse.rawValue, msg: error.localizedDescription)
            completion(nil, [:], serviceError)
        }
    }
    
    //expects json Content-Type
    @discardableResult
    func send(urlRequest request: URLRequest, completion: @escaping RemoteTransportCompletionHandler) -> Any? {
        
        if let data = request.httpBody {
            
            do {
                let jsonObj = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                dlog("posting jsonObj type: \(type(of: jsonObj)), content: \(jsonObj)")
            }
            catch {
                dlog("error: \(error)")
            }
            
        }
        
        let dataTask = session.dataTask(with: request, completionHandler:
        { [weak self] (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            guard let myself = self else { return }
            
            guard let localResp = response as? HTTPURLResponse else {
                let error = ServiceError(type: .invalidResponse, code: ServiceErrorCode.notFound.rawValue, msg: "unknown response type")
                myself.handleCompletion(nil, nil, error, completion)
                return
            }
            
            let contentType = localResp.allHeaderFields["Content-Type"] as? String ?? ""
            let statusCode = localResp.statusCode
            dlog("responseUrl: \(String(describing: localResp.url))")
            dlog("responseCode: \(statusCode)")
            dlog("contentType: \(contentType)")
            
            if let foundError = error {
                dlog("error: \(foundError)")
                myself.handleCompletion(nil, nil, ServiceError(foundError), completion)
            }
            else if statusCode >= 400 && statusCode <= 600 {
                var msg = HTTPURLResponse.localizedString(forStatusCode: statusCode)
                //maybe it's a nice server
                if let foundData = data, let errStr = String(data: foundData, encoding: .utf8) {
                    msg = errStr
                }
                let error = ServiceError(type: .httpServer, code: statusCode, msg: msg)
                myself.handleCompletion(nil, nil, error, completion)
            }
            else if let foundData = data {
                if (contentType.contains("json")) { //success
                    myself.handleCompletion(foundData, localResp, nil, completion)
                }
                else {
                    let msg = "contentType is not json: \(contentType)"
                    dlog(msg)
                    let error = ServiceError(type: .invalidData, code: ServiceErrorCode.parse.rawValue, msg: msg)
                    myself.handleCompletion(nil, nil, error, completion)
                }
            }
            else {
                let msg = "unknown error"
                dlog(msg)
                let error = ServiceError(type: .unknown, code: ServiceErrorCode.unknown.rawValue, msg: msg)
                myself.handleCompletion(nil, nil, error, completion)
            }
        })
        
        dataTask.resume()
        
        return dataTask
    }
    
    fileprivate func handleCompletion(_ data: Data?, _ resp: HTTPURLResponse?, _ error: Error?, _ completion: @escaping RemoteTransportCompletionHandler) {
        //DispatchQueue.main.async {
        var headers = resp?.allHeaderFields
        headers?["statusCode"] = resp?.statusCode ?? 0

        completion(data, headers ?? [:], error)
        //}
    }
    
    var description: String {
        return JsonHttpTransport.staticName
    }
    
    class var staticName: String {
        return "JsonHttpTransport"
    }
}
