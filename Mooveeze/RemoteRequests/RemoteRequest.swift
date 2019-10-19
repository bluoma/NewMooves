//
//  Request.swift
//  Mooveeze
//
//  Created by Bill on 10/17/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation



class RemoteRequest {
    
    var method: String = ""
    var version: String = ""
    var resourcePath: String = ""
    var params: [String: String] = [:]
    var contentType: String = ""
    var contentBody: [String: AnyObject] = [:]
    var requiresSession: Bool = false
    
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
    
}
