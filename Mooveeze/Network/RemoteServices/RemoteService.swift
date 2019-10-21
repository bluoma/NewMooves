//
//  RemoteService.swift
//  Mooveeze
//
//  Created by Bill on 10/21/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

class RemoteService: CustomStringConvertible {
    
    var description: String {
        return RemoteService.staticName
    }
    
    class var staticName: String {
        return "RemoteService"
    }
}
