//
//  UserProfile.swift
//  Mooveeze
//
//  Created by Bill on 9/5/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

struct UserProfile: Codable, CustomStringConvertible, CustomDebugStringConvertible {

    /*
     {
     "avatar": {
     "gravatar": {
     "hash": "c9e9fc152ee756a900db85757c29815d"
     }
     },
     "id": 548,
     "iso_639_1": "en",
     "iso_3166_1": "CA",
     "name": "Travis Bell",
     "include_adult": true,
     "username": "travisbell"
     }
    */
    
    struct Avatar: Codable {
        struct Gravatar: Codable {
            let hash: String
            
            enum CodingKeys: String, CodingKey {
                case hash
            }
        }
        let gravatar: Gravatar
        
        enum CodingKeys: String, CodingKey {
            case gravatar
        }
    }
    let avatar: Avatar
    let profileId: Int
    let language: String
    let region: String
    let fullname: String
    let includeAdult: Bool
    let username: String

    enum CodingKeys: String, CodingKey {
        
        case avatar
        case profileId = "id"
        case language = "iso_639_1"
        case region = "iso_3166_1"
        case fullname = "name"
        case includeAdult = "include_adult"
        case username
    }
    
    var description: String {
        return "profileId: \(profileId), hash: \(avatar.gravatar.hash), username: \(username)"
    }
    
    var debugDescription: String {
        return "profileId: \(profileId), hash: \(avatar.gravatar.hash), username: \(username)"
    }

}
