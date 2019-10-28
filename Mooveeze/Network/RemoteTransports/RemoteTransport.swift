//
//  RemoteTransport.swift
//  MoreClients
//
//  Created by Bill on 10/25/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

enum TransportState: String {
    case connected = "connected"
    case connecting = "connecting"
    case disconnected = "disconnected"
    case disconnecting = "disconnecting"
}

typealias RemoteTransportCompletionHandler = (Data?, [AnyHashable: Any], Error?) -> Void

protocol RemoteTransport {
    
    var connectBlock: (() -> Void)? { get set }
    var disconnectBlock: ((Error?) -> Void)? { get set }
    var shouldRetryBlock: ((URLRequest, Bool) -> Void)? { get set }
    
    func connect()
    func disconnect()
    
    func send(urlRequest request: URLRequest, completion: @escaping RemoteTransportCompletionHandler) -> Any?
    
}
