//
//  NetworkService.swift
//  Mooveeze
//
//  Created by Bill on 10/18/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation


class NetworkService {
    
    fileprivate var clientRequestDict: [String: RemoteClient] = [:]
    fileprivate var requestTaskDict: [RemoteRequest: AnyObject] = [:]
    fileprivate var jsonService = JsonHttpService()
    fileprivate let requestTaskDictLock = NSLock()
    
    fileprivate init() {
        let client = MovieDbClient()
        clientRequestDict[MovieRequest.staticName] = client
        clientRequestDict[UserAccountRequest.staticName] = client
    }
    
    static var shared: NetworkService = NetworkService()
    
    func clientForRequest(name: String) -> RemoteClient? {
        return clientRequestDict[name]
    }
    
    func taskForRequest(_ request: RemoteRequest) -> AnyObject? {
        requestTaskDictLock.lock()
        defer {
            requestTaskDictLock.unlock()
        }
        return requestTaskDict[request]
    }
    
    func addTask(_ task: AnyObject, forRequest request: RemoteRequest) {
        requestTaskDictLock.lock()
        requestTaskDict[request] = task
        requestTaskDictLock.unlock()
    }
    
    func removeTask(forRequest request: RemoteRequest) {
        requestTaskDictLock.lock()
        requestTaskDict[request] = nil
        requestTaskDictLock.unlock()
    }
    
    func jsonRestSend(remoteRequest: RemoteRequest) -> Any? {
        
        guard let client = clientForRequest(name: remoteRequest.description) else {
            let error = ServiceError(type: .invalidRequest, code: ServiceErrorCode.invalidClient.rawValue, msg: "No client for request \(String(describing: self))")
            remoteRequest.failureBlock?(error)
            return nil
        }
        
        guard let urlRequest = client.buildUrlRequest(withRemoteRequest: remoteRequest) else {
            let error = ServiceError(type: .invalidRequest, code: ServiceErrorCode.invalidRequest.rawValue, msg: "No urlRequest from client: \(String(describing: client))")
            remoteRequest.failureBlock?(error)
            return nil
        }
        
        let task: URLSessionDataTask = jsonService.send(urlRequest: urlRequest, completion:
        { [weak self] (data: Data?, response: HTTPURLResponse?, error: Error?) in
            
            guard let myself = self else { return }
            
            if let error = error {
                remoteRequest.failureBlock?(error)
            }
            else {
                var headers = response?.allHeaderFields ?? [:]
                headers["statusCode"] = response?.statusCode ?? 0
                remoteRequest.successBlock?(data, headers)
            }
            myself.removeTask(forRequest: remoteRequest)
        })
        
        addTask(task, forRequest: remoteRequest)
        
        return task
        
    }
    
}
