//
//  UserProfile.swift
//  Mooveeze
//
//  Created by Bill on 9/5/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

class UserProfile: CustomStringConvertible, CustomDebugStringConvertible {

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
    
    var avatarHash: String = ""
    var profileId: Int = -1
    var language: String = ""
    var location: String = ""
    var fullname = ""
    var includeAdult: Bool = true
    var username: String = ""

    
    convenience init(jsonDict: NSDictionary) {
        self.init()
        
        if let profileId = jsonDict["id"] as? Int {
            self.profileId = profileId
        }
        if let avatarHash = jsonDict.value(forKeyPath: "avatar.gavatar.hash") as? String {
            self.avatarHash = avatarHash
        }
        if let language = jsonDict["iso_639_1"] as? String {
            self.language = language
        }
        if let location = jsonDict["iso_3166_1"] as? String {
            self.location = location
        }
        if let fullname = jsonDict["name"] as? String {
            self.fullname = fullname
        }
        if let includeAdult = jsonDict["include_adult"] as? Bool {
            self.includeAdult = includeAdult
        }
        if let username = jsonDict["username"] as? String {
            self.username = username
        }
    }
    
    var description: String {
        return "profileId: \(profileId), fullname: \(fullname), username: \(username)"
    }
    
    var debugDescription: String {
        return "profileId: \(profileId), fullname: \(fullname), username: \(username)"
    }

}
