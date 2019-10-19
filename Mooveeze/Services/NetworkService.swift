//
//  NetworkService.swift
//  Mooveeze
//
//  Created by Bill on 10/18/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation


class NetworkService {
    
    var clientRequestDict: [String: RemoteClient] = [:]
    var requestTaskDict: [RemoteRequest: AnyObject] = [:]
    
    init() {
        
        let client = MovieDbClient()
        clientRequestDict["MovieRequest"] = client
        clientRequestDict["UserAccountRequest"] = client
    }
    
    static var shared: NetworkService = NetworkService()
    
    func clientForRequest(name: String) -> RemoteClient? {
        return clientRequestDict[name]
    }
    
    //TODO: synchronize access
    func taskForRequest(_ request: RemoteRequest) -> AnyObject? {
        return requestTaskDict[request]
    }
    
    func addTask(_ task: AnyObject, forRequest request: RemoteRequest) {
        requestTaskDict[request] = task
    }
    
    func removeTask(forRequest request: RemoteRequest) {
        requestTaskDict[request] = nil
    }
}
