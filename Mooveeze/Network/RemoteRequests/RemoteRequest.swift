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


protocol RequestProtocol: AnyObject {
        
    var method: String { get set }
    var version: String { get set }
    var resourcePath: String { get set }
    var params: [String: String] { get set }
    var contentType: String { get set }
    var contentBody: [String: AnyObject] { get set }
    var requiresSession: Bool { get set }
    var fullPath: String { get }
    var successBlock: RequestSuccessBlock? {get set}
    var failureBlock: RequestFailureBlock? {get set}
    
    func appendPath(_ path: String)
    func send()
}


class RemoteRequest: Hashable, CustomStringConvertible {
    
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
    
    var description: String {
        return "RemoteRequest"
    }
    
    @discardableResult func send() -> Any? {
        return nil
    }
    
    static func == (lhs: RemoteRequest, rhs: RemoteRequest) -> Bool {
           
        let eq = lhs.method == rhs.method &&
            lhs.version == rhs.version &&
            lhs.fullPath == rhs.fullPath &&
            lhs.params == rhs.params &&
            lhs.contentType == rhs.contentType &&
            lhs.contentBody == rhs.contentBody
        
        return eq
    }
       
    func hash(into hasher: inout Hasher) {
        hasher.combine(method)
        hasher.combine(version)
        hasher.combine(fullPath)
        hasher.combine(params)
        hasher.combine(contentType)
        hasher.combine(contentBody)
    }
}
