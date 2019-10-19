//
//  HttpClient.swift
//  Mooveeze
//
//  Created by Bill on 10/17/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

class HttpClient: RemoteClient {

    var headers: [String: String] = [:]
    
    override func buildUrl(withRequest request: RemoteRequest) -> URL? {
        
        var url: URL? = nil
        
        var components: URLComponents = URLComponents()
        if !scheme.isEmpty {
            components.scheme = scheme
        }
        if !host.isEmpty {
            components.host = host
        }
        if !port.isEmpty {
            components.port = Int(port)
        }
        if !request.fullPath.isEmpty {
            components.path = request.fullPath
        }
        if !request.params.isEmpty {
            
            var items: [URLQueryItem] = []
            for (name, value) in request.params {
                let percentEncodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                let item: URLQueryItem = URLQueryItem(name: name, value: percentEncodedValue)
                items.append(item)
            }
            components.queryItems = items
        }
    
        url = components.url
        dlog("url: \(String(describing: url))")
        
        return url
    }
    
    
    override func buildUrlRequest(withRemoteRequest request: RemoteRequest) -> URLRequest? {
        
        var urlRequest: URLRequest?
        
        if let url = buildUrl(withRequest: request) {
            
            urlRequest = URLRequest(url: url)
            if !headers.isEmpty {
                urlRequest?.allHTTPHeaderFields = headers
                urlRequest?.httpMethod = request.method
            }
        }
        
        return urlRequest
    }
    

}
