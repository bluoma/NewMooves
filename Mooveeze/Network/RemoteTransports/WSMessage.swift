//
//  WSMessage.swift
//  MoreClients
//
//  Created by Bill on 10/25/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

class WSMessage: Encodable, Hashable, CustomStringConvertible {
    
    var id: String = ""
    var timeStamp: Date = Date()
    var resource: String = ""
    var body: Data?
    
    init(id: String, timeStamp: Date, resource: String, body: Data? = nil) {
        self.id = id
        self.timeStamp = timeStamp
        self.resource = resource
        self.body = body
    }
    
    //custom decoding because 'body' can be a json dict or a json array of dicts
    //we need to convert json to Data for downstream parsing
    init(withDict dict: [String: AnyObject]) {
        
        if let id = dict["id"] as? String {
            self.id = id
        }
        if let timeStampString = dict["timeStamp"] as? String {
            let formatter = ISO8601DateFormatter()
            if let iso8601Date = formatter.date(from: timeStampString) {
                self.timeStamp = iso8601Date
            }
        }
        if let resource = dict["resource"] as? String {
            self.resource = resource
        }
        if let body = dict["body"] as? [String: AnyObject] {
            setDataOnBody(body)
        }
        else if let body = dict["body"] as? [[String: AnyObject]] {
            setDataOnBody(body)
        }
        else {
            dlog("body is not array or dict: \(String(describing: dict["body"]))")
        }
    }
    
    fileprivate func setDataOnBody(_ jsonObj: Any) {
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonObj, options: [])
            self.body = data
            dlog("bodyData: \(data) as array of dict")
        }
        catch {
            dlog("error converting \(type(of: jsonObj)) to data: \(error)")
        }
    }
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case timeStamp
        case resource
        case body
    }
    
    var description: String {
        return "id: \(id) for resource: \(resource) timeStamp: \(timeStamp)"
    }
    
    static func messageFrom(request: URLRequest) -> WSMessage? {
        
        guard let query = request.url?.query else {
            dlog("no query in request: \(request)")
            return nil
        }
        var params: [String: String] = [:]
        let keyvalsArray = query.split(separator: "&")
        for keyval in keyvalsArray {
            let keyvalString = String(keyval)
            let keyvalPair = keyvalString.split(separator: "=")
            if keyvalPair.count == 2 {
                let key = String(keyvalPair[0])
                let val = String(keyvalPair[1])
                params[key] = val
            }
        }
        guard let messageId = params["messageId"] else {
            dlog("no messageId in query: \(query)")
            return nil
        }
        guard let urlString = request.url?.absoluteString else {
            dlog("no url in request: \(request)")
            return nil
        }
        
        return WSMessage(id: messageId, timeStamp: Date(), resource: urlString, body: request.httpBody)
    }
    
    static func == (lhs: WSMessage, rhs: WSMessage) -> Bool {
        let eq = lhs.id == rhs.id
        return eq
    }
       
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
