//
//  ProfileCoordinator.swift
//  Mooveeze
//
//  Created by Bill on 9/5/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import UIKit

class ProfileCoordinator: BaseRootNavigationCoordinator {
    
    unowned var profileViewController: ProfileViewController
    
    override init(withNavVc navVc: UINavigationController, config: CoordinatorConfig) {
        
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: ProfileViewController.self)) as? ProfileViewController else {
            fatalError()
        }
        
        profileViewController = vc
        profileViewController.title = config.vcTitle
        navVc.viewControllers.append(profileViewController)
        
        super.init(withNavVc: navVc, config: config)
        
    }
    
}
