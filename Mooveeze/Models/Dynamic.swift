//
//  Dynamic.swift
//  Mooveeze
//
//  Created by Bill on 9/9/19.
//  Copyright © 2019 Bill. All rights reserved.
//
// copied from http://rasic.info/bindings-generics-swift-and-mvvm/
// implements unidirection binding for simple types
import Foundation

class Dynamic<T> {
    typealias Listener = ((T) -> Void)
    var listener: Listener?
    
    func bind(listener: Listener?) {
        self.listener = listener
    }
    
    func bindAndFire(listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    init(_ v: T) {
        value = v
    }
}
