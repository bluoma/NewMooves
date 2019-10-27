//
//  JsonWsRequest.swift
//  MoreClients
//
//  Created by Bill on 10/24/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

class JsonWsRequest: RemoteRequest {
    
    
    @discardableResult override func send() -> Any? {
        dlog("forwarding to NetworkService.send: \(self)")
        return NetworkPlatform.shared.send(remoteRequest: self)
    }
    
    override var description: String {
        return JsonWsRequest.staticName
    }
    
    override class var staticName: String {
        return "JsonWsRequest"
    }
    
}
