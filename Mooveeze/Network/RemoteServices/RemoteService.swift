//
//  RemoteService.swift
//  Mooveeze
//
//  Created by Bill on 10/21/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

protocol RemoteService: CustomStringConvertible {
    
    static var staticName: String { get }
   
}
