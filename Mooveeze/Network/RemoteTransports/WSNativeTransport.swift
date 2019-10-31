//
//  WSNativeTransport.swift
//  Mooveeze
//
//  Created by Bill on 10/27/19.
//  Copyright © 2019 Bill Luoma. All rights reserved.
//

import Foundation

@available(iOS 13, *)
class WSNativeTransport: NSObject, RemoteTransport {
    
    let baseUrl: URL
    var messageMap: [WSMessage: RemoteTransportCompletionHandler] = [:]
    var transportState: TransportState = .disconnected
    
    lazy var session: URLSession = {
        let urlconfig = URLSessionConfiguration.default
        //urlconfig.timeoutIntervalForRequest = 12
        //urlconfig.timeoutIntervalForResource = 12
        //urlconfig.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        let newSession = URLSession(configuration: urlconfig, delegate: self, delegateQueue: OperationQueue())
        return newSession
    } ()
    
    lazy var task: URLSessionWebSocketTask = {
        let newTask = session.webSocketTask(with: baseUrl)
        return newTask
    } ()
    
    var connectBlock: (() -> Void)?
    var disconnectBlock: ((Error?) -> Void)?
    var shouldRetryBlock: ((URLRequest, Bool) -> Void)?

    
    init(withBaseUrl url: URL) {
        baseUrl = url
        super.init()
    }
    
    func connect() {
        guard transportState == .disconnected else { return }
        transportState = .connecting
        task.resume()
    }
    
    func disconnect() {
        guard transportState == .connected else { return }
        transportState = .disconnecting
        task.cancel(with: .goingAway, reason: nil)
    }

    func receive() {
        guard transportState == .connected else {
            dlog("socket not connected, breaking out of receive recurse")
            return
        }
        
        task.receive(completionHandler:
        { [weak self] (result: Result<URLSessionWebSocketTask.Message, Error>) -> Void in
            
            guard let myself = self else { return }
            
            switch result {
                
            case .failure(let error):
                dlog("receiveError: \(error)")
                DispatchQueue.main.async {
                    self?.disconnect()
                }
                
            case .success(let message):
                
                switch message {
                    
                case .string(let text):
                    DispatchQueue.main.async {
                        myself.websocketDidReceiveText(text: text)
                    }

                case .data(let data):
                    DispatchQueue.main.async {
                        myself.websocketDidReceiveData(data: data)
                    }

                @unknown default:
                    fatalError()
                }
                
                myself.receive()
            }
        })
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
        dlog("thread: \(Thread.current)")
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
            let wsMessage = URLSessionWebSocketTask.Message.data(serialized)
            task.send(wsMessage, completionHandler: { [weak self] (error: Error?) -> Void in
                dlog("sent: \(error?.localizedDescription ?? "OK")")
                if error == nil {
                    self?.messageMap[message] = completion //store completion for repsonse
                }
            })
            return message
        }
        catch {
            dlog("error encoding message: \(error)")
            completion(nil, [:], error)
            return nil
        }
    }
    
    func startPinging() {
        dlog("in")
        guard transportState == .connected else { return }
        
        task.sendPing(pongReceiveHandler: { (error: Error?) -> Void in
            dlog("sendPing: \(error?.localizedDescription ?? "OK")")
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
          self.startPinging()
        }
        dlog("out")

    }
    
    override var description: String {
        return WSNativeTransport.staticName
    }
    
    class var staticName: String {
        return "WSNativeTransport"
    }
}

@available(iOS 13, *)
extension WSNativeTransport: URLSessionWebSocketDelegate {
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        dlog("protocol: \(String(describing: `protocol`))")
        
        DispatchQueue.main.async{ [weak self] in
            self?.transportState = .connected
            self?.receive()
            self?.connectBlock?()
            self?.startPinging()
        }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        dlog("closeCode: \(closeCode)")
        DispatchQueue.main.async{ [weak self] in
            self?.transportState = .disconnected
            self?.disconnectBlock?(nil)
        }
    }
    
}
