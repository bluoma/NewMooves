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
    fileprivate var jsonTransport = JsonHttpTransport()
    fileprivate let requestTaskDictLock = NSLock()
    
    fileprivate init() {
        loadNetworkPlist(forEnv: buildEnv)
        dlog("remoteClients: \(remoteClients)")
        dlog("requestClientDict: \(requestClientDict)")
        precondition(!remoteClients.isEmpty, "no remote clients")
        precondition(!requestClientDict.isEmpty, "no requst client mapping")
    }
    
    static var shared: NetworkPlatform = NetworkPlatform()
    
    var buildEnv: BuildEnv {
        #if DEBUG
        let env = BuildEnv.dev
        #elseif RELEASE
        let env = BuildEnv.prod
        #else
        let env = BuildEnv.qa
        #endif
        return env
    }
    
    
    fileprivate func loadNetworkPlist(forEnv env: BuildEnv) {
        
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
            return
        }
        
        guard let clientsArray = plistDict["remoteClients"] as? [[String: String]] else { return }
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
                remoteClients.append(client)
            }
        }
        
        guard let reqClientDict = plistDict["requestClientDict"] as? [String: String] else { return }
        for (key, val) in reqClientDict {
            if let client = remoteClients.first(where: { $0.description == val }) {
                requestClientDict[key] = client
            }
        }
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
        
        let task: URLSessionDataTask = jsonTransport.send(urlRequest: urlRequest, completion:
        { [weak self] (data: Data?, response: HTTPURLResponse?, error: Error?) in
            
            guard let myself = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    remoteRequest.failureBlock?(error)
                }
            }
            else {
                var headers = response?.allHeaderFields ?? [:]
                headers["statusCode"] = response?.statusCode ?? 0
                DispatchQueue.main.async {
                    remoteRequest.successBlock?(data, headers)
                }
            }
            myself.removeTask(forRequest: remoteRequest)
        })
        
        addTask(task, forRequest: remoteRequest)
        
        return task
        
    }
    
}
