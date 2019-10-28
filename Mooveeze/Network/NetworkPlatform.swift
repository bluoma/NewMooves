//
//  NetworkPlatform.swift
//  Mooveeze
//
//  Created by Bill on 10/18/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

public enum BuildEnv: String {
    case dev = "dev"
    case qa = "qa"
    case prod = "prod"
}

class NetworkPlatform {
    
    fileprivate var remoteClients: [RemoteClient] = []
    fileprivate var requestClientDict: [String: RemoteClient] = [:]
    fileprivate var requestTaskDict: [RemoteRequest: Any] = [:]
    fileprivate let requestTaskDictLock = NSLock()
    
    fileprivate init() {
        let containers: (array: [RemoteClient], dict: [String: RemoteClient]) = NetworkPlatform.loadNetworkPlist(forEnv: NetworkPlatform.buildEnv)
        precondition(containers.array.count > 1, "no remote clients")
        precondition(!containers.dict.isEmpty, "no requst client mapping")
        remoteClients = containers.array
        requestClientDict = containers.dict
        dlog("remoteClients: \(remoteClients)")
        dlog("requestClientDict: \(requestClientDict)")
    }
    
    static var shared: NetworkPlatform = NetworkPlatform()
    
    static var buildEnv: BuildEnv {
        #if DEBUG
        let env = BuildEnv.dev
        #elseif RELEASE
        let env = BuildEnv.prod
        #else
        let env = BuildEnv.qa
        #endif
        return env
    }
    
    
    fileprivate static func loadNetworkPlist(forEnv env: BuildEnv) -> ([RemoteClient], [String: RemoteClient]){
        
        var clients: [RemoteClient] = []
        var requestMap: [String: RemoteClient] = [:]
        
        let plistName: String
        
        switch env {
        case .dev:
            plistName = "Network"
        case .qa:
            plistName = "Network"
        case .prod:
            plistName = "Network"
        }
        
        let plistDict = readPropertyList(plistName)
        guard !plistDict.isEmpty else {
            dlog("Error no plistDict found")
            return (clients, requestMap)
        }
        
        guard let clientsArray = plistDict["remoteClients"] as? [[String: String]] else {
            return (clients, requestMap)
        }
        for clientDict in clientsArray {
            guard let clientName = clientDict["client"] else { continue }
            //create MovieDbClient
            if clientName == MovieDbClient.staticName {
                guard let scheme = clientDict["scheme"], let host = clientDict["host"] else {
                    dlog("Error no scheme/host for MovieDbClient in plist")
                    continue
                }
                let client: MovieDbClient
                if let port = clientDict["port"] {
                    client = MovieDbClient(withScheme: scheme, host: host, port: port)
                }
                else {
                    client = MovieDbClient(withScheme: scheme, host: host)
                }
                clients.append(client)
            }
            //create WSClient
            if clientName == WSClient.staticName {
                guard let scheme = clientDict["scheme"], let host = clientDict["host"] else {
                    dlog("Error no scheme/host for WSClient in plist")
                    continue
                }
                let client: WSClient
                if let port = clientDict["port"] {
                    client = WSClient(withScheme: scheme, host: host, port: port)
                }
                else {
                    client = WSClient(withScheme: scheme, host: host)
                }
                clients.append(client)
            }
        }
        
        guard let reqClientDict = plistDict["requestClientDict"] as? [String: String] else {
            return (clients, requestMap)
            
        }
        for (key, val) in reqClientDict {
            if let client = clients.first(where: { $0.description == val }) {
                requestMap[key] = client
            }
        }
        return (clients, requestMap)
    }
    
    func clientForRequest(name: String) -> RemoteClient? {
        return requestClientDict[name]
    }
    
    func taskForRequest(_ request: RemoteRequest) -> Any? {
        requestTaskDictLock.lock()
        defer {
            requestTaskDictLock.unlock()
        }
        return requestTaskDict[request]
    }
    
    func addTask(_ task: Any, forRequest request: RemoteRequest) {
        requestTaskDictLock.lock()
        requestTaskDict[request] = task
        requestTaskDictLock.unlock()
    }
    
    func removeTask(forRequest request: RemoteRequest) {
        requestTaskDictLock.lock()
        requestTaskDict[request] = nil
        requestTaskDictLock.unlock()
    }
    
    func send(remoteRequest: RemoteRequest) -> Void {
        
        guard let client = clientForRequest(name: remoteRequest.description) else {
            let error = ServiceError(type: .invalidRequest, code: ServiceErrorCode.invalidClient.rawValue, msg: "No client for request \(String(describing: self))")
            remoteRequest.failureBlock?(error)
            return
        }
        
        guard let urlRequest = client.buildUrlRequest(withRemoteRequest: remoteRequest) else {
            let error = ServiceError(type: .invalidRequest, code: ServiceErrorCode.invalidRequest.rawValue, msg: "No urlRequest from client: \(String(describing: client))")
            remoteRequest.failureBlock?(error)
            return
        }
        //forward to client 
        let task = client.send(urlRequest: urlRequest, completion:
        {
            [weak self] (data: Data?, headers: [AnyHashable: Any], error: Error?) in
            
            guard let myself = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    remoteRequest.failureBlock?(error)
                }
            }
            else {
                DispatchQueue.main.async {
                    remoteRequest.successBlock?(data, headers)
                }
            }
            myself.removeTask(forRequest: remoteRequest)
        })
        
        if let foundtask = task {
            addTask(foundtask, forRequest: remoteRequest)
        }
    }
}
