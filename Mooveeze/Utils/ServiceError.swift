//
//  Error.swift
//  Mooveeze
//
//  Created by Bill on 9/11/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

enum ServiceErrorCode: Int {
    case parse = -400
    case notFound = -404
    case unknown = -600
    
}

enum ServiceErrorType: String {
    
    case invalidUrl = "invalidUrl"
    case invalidRequest = "invalidRequest"
    case invalidResponse = "invalidResponse"
    case httpServer = "httpServer"
    case invalidData = "invalidData"
    case external = "external"
    case unknown = "unknown"
}


struct ServiceError: Error {
    
    var type: ServiceErrorType = .unknown
    var msg = ""
    var code: Int = 0
    var file: String = ""
    var function: String = ""
    var line: Int = 0
    var domain: String = "Mooveeze"
    
    
    init(type: ServiceErrorType, code: Int = 0, msg: String, file: String = #file, function: String = #function, line: Int = #line) {
        self.type = type
        self.msg = msg
        self.code = code
        self.file = file
        self.function = function
        self.line = line
    }
    
    init(_ error: Error, file: String = #file, function: String = #function, line: Int = #line) {
        self.type = .external
        self.msg = error.localizedDescription
        self.code = (error as NSError).code
        self.domain = (error as NSError).domain
        self.file = file
        self.function = function
        self.line = line
    }
    
}
