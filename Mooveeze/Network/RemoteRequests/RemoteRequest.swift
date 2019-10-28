//
//  Request.swift
//  Mooveeze
//
//  Created by Bill on 10/17/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation


typealias RequestSuccessBlock = (Data?, [AnyHashable: Any]) -> Void
typealias RequestFailureBlock = (Error) -> Void

class RemoteRequest: Hashable, CustomStringConvertible {
    
    let requestId: String = UUID().uuidString
    var method: String = ""
    var version: String = ""
    var resourcePath: String = ""
    var params: [String: String] = [:]
    var contentType: String = ""
    var contentBody: [String: String] = [:]
    var requiresSession: Bool = false
    
    var successBlock: RequestSuccessBlock?
    var failureBlock: RequestFailureBlock?
    
    
    init() {
        
    }
    
    var fullPath: String {
        var p = ""
        
        if !version.isEmpty  {
            if !version.hasPrefix("/") {
                p.append("/")
            }
            p.append(version)
        }
        if !resourcePath.isEmpty  {
            if !resourcePath.hasPrefix("/") {
                p.append("/")
            }
            p.append(resourcePath)
        }
        
        return p
    }
    
    func appendPath(_ path: String) {
        
        if !path.hasPrefix("/") {
            self.resourcePath.append(contentsOf: "/")
        }
        self.resourcePath.append(path)
    }
    
    func send() -> Any? {
        return nil
    }
    
    var description: String {
        return RemoteRequest.staticName
    }
    
    class var staticName: String {
        return "RemoteRequest"
    }
    
    static func == (lhs: RemoteRequest, rhs: RemoteRequest) -> Bool {
        let eq = lhs.requestId == rhs.requestId
        return eq
    }
       
    func hash(into hasher: inout Hasher) {
        hasher.combine(requestId)
    }
}
