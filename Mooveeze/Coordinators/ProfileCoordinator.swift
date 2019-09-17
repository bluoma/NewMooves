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
    var registerController: RegisterController?
    
    override init(withNavVc navVc: UINavigationController, config: CoordinatorConfig) {
        
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: ProfileViewController.self)) as? ProfileViewController else {
            fatalError()
        }
        
        profileViewController = vc
        
        super.init(withNavVc: navVc, config: config)
        let viewModel = ProfileViewModel()
        profileViewController.profileViewModel = viewModel
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
        vc.loginViewModel = LoginViewModel()
        vc.loginDidSucceed = loginViewControllerDidSucceed
        vc.loginDidCancel = loginViewControllerDidCancel
        vc.loginDidErr = loginViewControllerDidError
        
        let loginModalNav = UINavigationController(rootViewController: vc)
        self.navigationController.present(loginModalNav, animated: true, completion: nil)
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
    
    func profileViewControllerDidSelectCreateAccount() {
        dlog("")
        let registerController = RegisterController()
        self.registerController = registerController
        let registerModalNav = UINavigationController(rootViewController: registerController.safari)
        self.navigationController.present(registerModalNav, animated: true, completion: nil)
    }
    
    func registerControllerDidSucceed(sessionId: String) {
        dlog("sessionId: \(sessionId)")
        //saveSessionId(sessionId)
        self.navigationController.dismiss(animated: true, completion: nil)
        self.registerController = nil
    }
    
    func registerControllerDidCancel() {
        dlog("")
        self.navigationController.dismiss(animated: true, completion: nil)
        self.registerController = nil
    }
    
    func registerControllerDidError(error: NSError?) {
        dlog(String(describing: error))
        self.navigationController.dismiss(animated: true, completion: nil)
        self.registerController = nil
    }
    
}
