//
//  JsonHttpService.swift
//  Mooveeze
//
//  Created by Bill on 10/3/16.
//  Copyright © 2016 Bill Luoma. All rights reserved.
//

import Foundation

typealias JsonHttpServiceCompletionHandler = (Data?, HTTPURLResponse?, NSError?) -> Void

class JsonHttpService {
    
    var session: URLSession!
    
    init() {
        let urlconfig = URLSessionConfiguration.default
        urlconfig.timeoutIntervalForRequest = 12
        urlconfig.timeoutIntervalForResource = 12
        //urlconfig.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        self.session = URLSession(configuration: urlconfig, delegate: nil, delegateQueue: nil)
    }
    
    func doGet(
        url: URL,
        completion: @escaping JsonHttpServiceCompletionHandler) {
    
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = send(request: request, completion: completion)
        task.resume()
    }
    
    func doPost(
        url: URL,
        postBody: [String: AnyObject],
        completion: @escaping JsonHttpServiceCompletionHandler) {
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let data = try JSONSerialization.data(withJSONObject: postBody, options: .prettyPrinted)
            request.httpBody = data
            let task = send(request: request, completion: completion)
            task.resume()
        }
        catch let jerr as NSError {
            dlog(String(describing: jerr))
            completion(nil, nil, jerr)
        }
    }
    
    //expects json dictionary as a response
    fileprivate func send(request: URLRequest, completion: @escaping JsonHttpServiceCompletionHandler) -> URLSessionDataTask {
        
        let dataTask = session.dataTask(with: request, completionHandler:
        { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            var returnedError: NSError?
            var dataActual: Data?
            var statusCode: Int = 0;
            var contentType: String = ""
            var httpResp: HTTPURLResponse?
            
            //called once at the end
            defer {
                DispatchQueue.main.async {
                    completion(dataActual, httpResp, returnedError)
                }
            }
            
            guard let localResp = response as? HTTPURLResponse else {
                returnedError = generateError(withCode: -404, msg: "unknown response type")
                return
            }
            
            //for the defer block above
            httpResp = localResp
            
            if let conType = localResp.allHeaderFields["Content-Type"] as? String {
                contentType = conType
            }
            statusCode = localResp.statusCode
            dlog("responseUrl: \(String(describing: localResp.url))")
            dlog("responseCode: \(statusCode)")
            
            if let foundError = error {
                dlog("error: \(foundError)")
                returnedError = foundError as NSError
            }
            else if statusCode >= 400 && statusCode <= 600 {
                var errDesc = HTTPURLResponse.localizedString(forStatusCode: statusCode)
                //maybe it's a nice server
                if let foundData = data, let errStr = String(data: foundData, encoding: .utf8) {
                    errDesc = errStr
                }
                returnedError = generateError(withCode: statusCode, msg: errDesc)
            }
            else if let foundData = data {
                if (contentType.contains("json")) {
                    dataActual = foundData //success
                }
                else {
                    let errString = "contentType is not json: \(contentType)"
                    dlog(errString)
                    returnedError = generateError(withCode: -400, msg: errString)
                }
            }
            else {
                let errString = "unknown error"
                dlog(errString)
                returnedError = generateError(withCode: -600, msg: errString)
            }
        })
        
        return dataTask
    }
}
