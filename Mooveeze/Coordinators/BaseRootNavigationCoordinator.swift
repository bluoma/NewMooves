//
//  BaseRootNavigationCoordinator.swift
//  Mooveeze
//
//  Created by Bill on 9/5/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import UIKit

class BaseRootNavigationCoordinator: BaseCoordinator {
    
    var configuration: CoordinatorConfig
    
    init(withNavVc navVc: UINavigationController, config: CoordinatorConfig) {
        configuration = config
        super.init(withNavVc: navVc)
    }
    
    
    
}
