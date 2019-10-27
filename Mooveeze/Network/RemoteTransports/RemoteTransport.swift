//
//  RemoteTransport.swift
//  MoreClients
//
//  Created by Bill on 10/25/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

typealias RemoteTransportCompletionHandler = (Data?, [AnyHashable: Any], Error?) -> Void

protocol RemoteTransport {
    
    func send(urlRequest request: URLRequest, completion: @escaping RemoteTransportCompletionHandler) -> Any?
    
}
