//
//  HttpRequest.swift
//  Mooveeze
//
//  Created by Bill on 10/18/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

class JsonHttpRequest: RemoteRequest {
        
    @discardableResult override func send() -> Any? {
        dlog("forwarding to NetworkService.jsonRestSend: \(self)")
        return NetworkService.shared.jsonRestSend(remoteRequest: self)
    }
    
    override var description: String {
        return "JsonHttpRequest"
    }
    
}

