//
//  TestUser.swift
//  MoreClients
//
//  Created by Bill on 10/24/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

struct TestUser: Codable, CustomStringConvertible, CustomDebugStringConvertible {
    
    let userId: Int
    let username: String
    let email: String
    let role: String
    let gravatar: String
    
    enum CodingKeys: String, CodingKey {
        
        case userId = "id"
        case username
        case email
        case role
        case gravatar
    }
    
    var description: String {
        return "userId: \(userId), username: \(username)"
    }
    
    var debugDescription: String {
        return description
    }
}
