//
//  BaseCoordinator.swift
//  Mooveeze
//
//  Created by Bill on 9/5/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import UIKit

class BaseCoordinator {
    
    unowned var navigationController: UINavigationController
    
    init(withNavVc navVc: UINavigationController) {
        navigationController = navVc
    }
    
    
    
}
