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
        
        super.init(withNavVc: navVc, config: config)
        
        profileViewController.title = config.vcTitle
        profileViewController.didSelectLogin = profileViewControllerDidSelectLogin
        profileViewController.didSelectCreateAccount = profileViewControllerDidSelectCreateAccount
        navVc.viewControllers.append(profileViewController)
        
    }
    
    func profileViewControllerDidSelectLogin() {
        dlog("")
        
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: LoginViewController.self)) as? LoginViewController else {
            fatalError()
        }
        vc.title = "Login to the Movie Db"
        vc.loginDidSucceed = loginViewControllerDidSucceed
        vc.loginDidCancel = loginViewControllerDidCancel
        vc.loginDidErr = loginViewControllerDidError
        
        let loginModalNav = UINavigationController(rootViewController: vc)
        self.navigationController.present(loginModalNav, animated: true, completion: nil)
    }
    
    func profileViewControllerDidSelectCreateAccount() {
        dlog("")
    }
    
    func loginViewControllerDidSucceed(sessionId: String) {
        dlog("sessionId: \(sessionId)")
        saveSessionId(sessionId)
        self.navigationController.dismiss(animated: true, completion: nil)
    }
    
    func loginViewControllerDidCancel() {
        dlog("")
        self.navigationController.dismiss(animated: true, completion: nil)
    }
    
    func loginViewControllerDidError(error: NSError?) {
        dlog(String(describing: error))
        self.navigationController.dismiss(animated: true, completion: nil)
    }
    
}
