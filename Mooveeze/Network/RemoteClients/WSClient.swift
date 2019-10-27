//
//  WebSocketClient.swift
//  MoreClients
//
//  Created by Bill on 10/23/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

class WSClient: RemoteClient {
    
    lazy var transport: RemoteTransport = {
        var wsTransport: RemoteTransport
        if #available(iOS 13, *) {
            wsTransport = WSNativeTransport(withBaseUrl: buildBaseUrl()!)
            wsTransport.connectBlock = wsTransportDidConnect
            wsTransport.disconnectBlock = wsTransportDidDisconnect(error:)
        }
        else {
            wsTransport = WSStarscreamTransport(withBaseUrl: buildBaseUrl()!)
            wsTransport.connectBlock = wsTransportDidConnect
            wsTransport.disconnectBlock = wsTransportDidDisconnect(error:)
        }
        return wsTransport
    } ()
    
    var headers: [String: String] = [:]
    
    init() {
        super.init(withScheme: "ws", host: "localhost", port: "9704")
        transport.connect()
    }
    
    override init(withScheme scheme: String, host: String, port: String = "") {
        super.init(withScheme: scheme, host: host, port: port)
        transport.connect()
    }
    
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
        
        guard let url = buildUrl(withRequest: request) else { return nil }
            
        var theUrlRequest = URLRequest(url: url)
        theUrlRequest.httpMethod = request.method
        
        if request.contentBody.isEmpty {
            urlRequest = theUrlRequest
        }
        else {
            switch request.contentType {
            case "application/json":
                do {
                    let data = try JSONSerialization.data(withJSONObject: request.contentBody, options: [])
                    theUrlRequest.httpBody = data
                    urlRequest = theUrlRequest
                    headers["Content-Type"] = "application/json"
                }
                catch {
                    dlog(String(describing: error))
                }
                
            default:
                dlog("unsupported contentType: \(request.contentType)")
            }
        }
       
        if !headers.isEmpty {
            urlRequest?.allHTTPHeaderFields = headers
        }
                
        return urlRequest
    }
    
    fileprivate func wsTransportDidConnect() {
        dlog("")
    }
    
    fileprivate func wsTransportDidDisconnect(error: Error?) {
        dlog("error: \(error?.localizedDescription ?? "no error")...")
        //TODO backoff strategy to reconnect
        //wsTransport.connect()
    }
    
    @discardableResult //forward to transport
    override func send(urlRequest request: URLRequest, completion: @escaping RemoteTransportCompletionHandler) -> Any? {
        return transport.send(urlRequest: request, completion: completion)
    }
    
    override var description: String {
        return WSClient.staticName
    }
    
    override class var staticName: String {
        return "WSClient"
    }
}


