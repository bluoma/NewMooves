//
//  WSStarscreamTransport.swift
//  MoreClients
//
//  Created by Bill on 10/24/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation
import Starscream

class WSStarscreamTransport: RemoteTransport {
        
    var messageMap: [WSMessage: RemoteTransportCompletionHandler] = [:]
    var transportState: TransportState = .disconnected
    let socket: WebSocket
    
    init(withBaseUrl url: URL) {
        socket = WebSocket(url: url)
        configureWebsocket()
        socket.connect()
    }
    
    var connectBlock: (() -> Void)?
    var disconnectBlock: ((Error?) -> Void)?
    var shouldRetryBlock: ((URLRequest, Bool) -> Void)?

    fileprivate func configureWebsocket() {
        socket.respondToPingWithPong = true
        socket.onConnect = webSocketDidConnect
        socket.onDisconnect = webSocketDidDisconnect(error:)
        socket.onText = websocketDidReceiveText(text:)
        socket.onData = websocketDidReceiveData(data:)
        socket.onPong = websocketDidReceivePong(data:)
    }
    
    func webSocketDidConnect() {
        transportState = .connected
        connectBlock?()
    }
    
    func webSocketDidDisconnect(error: Error?) {
        dlog("\(error?.localizedDescription ?? "no error")")
        transportState = .disconnected
        disconnectBlock?(error)
    }
    
    func websocketDidReceivePong(data: Data?) {
        dlog("pongData: \(String(describing: data))")
    }
    
    func websocketDidReceiveText(text: String) {
        dlog("thread: \(Thread.current)")
        dlog("text: \(text)")
        
        guard let data = text.data(using: .utf8) else {
            dlog("could not convert text to data")
            return
        }
        
        do {
            if let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject] {
                let message = WSMessage(withDict: jsonObject) //need to custom decode for body
                dlog("decodedMessage: \(message)")
                if let completionHandler = messageMap[message] {
                    completionHandler(message.body, ["statusCode": 200], nil)
                    messageMap[message] = nil
                }
                else {
                    dlog("no completion handler for message: \(message)")
                }
            }
            else {
                dlog("error decoding message not a jsonDict")
            }
        }
        catch {
            dlog("error decoding message: \(error)")
        }
    }
    
    func websocketDidReceiveData(data: Data) {
        dlog("data: \(data)")
        do {
            if let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject] {
                let message = WSMessage(withDict: jsonObject)
                dlog("decodedMessage: \(message)")
                if let completionHandler = messageMap[message] {
                    completionHandler(message.body, ["statusCode": 200], nil)
                    messageMap[message] = nil
                }
                else {
                    dlog("no completion handler for message: \(message)")
                }
            }
            else {
                dlog("error decoding message not a jsonDict")
            }
        }
        catch {
            dlog("error decoding message: \(error)")
        }

    }
    
    func connect() {
        guard transportState == .disconnected else { return }
        transportState = .connecting
        socket.connect()
    }
    
    func disconnect() {
        guard transportState == .connected else { return }
        transportState = .disconnecting
        socket.disconnect()
    }
    
    func sendPing(withText text: String) {
        guard transportState == .connected, let data = text.data(using: .utf8) else {
            return
        }
        dlog("sendPing: \(text)")
        socket.write(ping: data)
    }
    
    func sendPong(withText text: String) {
        guard transportState == .connected, let data = text.data(using: .utf8) else {
            return
        }
        dlog("sendPong: \(text)")
        socket.write(pong: data)
    }
    
    func sendMessage(withText text: String) {
        guard transportState == .connected else { return }

        socket.write(string: text)
    }
    
    func sendMessage(withData data: Data) {
        guard transportState == .connected else { return }
        
        socket.write(data: data)
    }
    
    //expects json Content-Type
    @discardableResult
    func send(urlRequest request: URLRequest, completion: @escaping RemoteTransportCompletionHandler) -> Any? {
        dlog("thread: \(Thread.current)")

        guard let message = WSMessage.messageFrom(request: request) else {
            dlog("no message in request: \(request)")
            let msg = "error converting URLRequest to message"
            let error = ServiceError(type: .invalidData, code: ServiceErrorCode.parse.rawValue, msg: msg)
            completion(nil, [:], error)
            return nil
        }
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let serialized = try encoder.encode(message)
            messageMap[message] = completion //store completion for repsonse
            sendMessage(withData: serialized)
            return message
        }
        catch {
            dlog("error encoding message: \(error)")
            completion(nil, [:], error)
            return nil
        }
    }
    
}

