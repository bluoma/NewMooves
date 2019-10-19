//
//  ProfileCoordinator.swift
//  Mooveeze
//
//  Created by Bill on 9/5/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import UIKit
import SafariServices

class ProfileCoordinator: BaseRootNavigationCoordinator {
    
    unowned var profileViewController: ProfileViewController
    
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
        
        //note Login VC can freeze when uitextfield becomes first responder due to ios13 simulator bug
        //on simulator, do Edit->Automatically Sync Pasteboard to deselect, followed by Hardware->Restart
        //see: https://forums.developer.apple.com/thread/122972
        
        vc.title = "Login to the Movie Db"
        vc.loginViewModel = LoginViewModel()
        vc.loginDidSucceed = loginViewControllerDidSucceed
        vc.loginDidCancel = loginViewControllerDidCancel
        vc.loginDidErr = loginViewControllerDidError
        
        let loginModalNav = UINavigationController(rootViewController: vc)
        //hack VC LifeCycle methods have changed in ios13 wrt to modal presentations
        //https://medium.com/@hacknicity/view-controller-presentation-changes-in-ios-13-ac8c901ebc4e
        loginModalNav.modalPresentationStyle = .fullScreen
        self.navigationController.present(loginModalNav, animated: true, completion:
        {() -> Void in
            dlog("presentation complete")
        })
        
    }
   
    func loginViewControllerDidSucceed(sessionId: String) {
        dlog("sessionId: \(sessionId)")
        saveSessionId(sessionId)
        self.navigationController.dismiss(animated: true, completion: { [weak self] ()-> Void in
        //hack VC LifeCycle methods have changed in ios13 wrt to modal presentations
        //https://medium.com/@hacknicity/view-controller-presentation-changes-in-ios-13-ac8c901ebc4e
            if #available(iOS 13, *) {
                //self?.profileViewController.handleRefresh()
                //if you don't present full screen above, uncomment so profileVC knows user is logged in
            }
        })
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
        
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: RegisterViewController.self)) as? RegisterViewController else {
            fatalError()
        }
        vc.title = "Create TMDb Account"
        vc.registerViewModel = RegisterViewModel()
        vc.registerShouldBrowse = self.registerControllerShouldBrowse
        vc.registerDidCancel = self.registerControllerDidCancel
        vc.registerDidErr = self.registerControllerDidError
        vc.registerDidSucceed = self.registerControllerDidSucceed
    
        let registerModalNav = UINavigationController(rootViewController: vc)
        self.navigationController.present(registerModalNav, animated: true, completion: nil)
    }
    
    func registerControllerDidSucceed(sessionId: String) {
        dlog("sessionId: \(sessionId)")
        saveSessionId(sessionId)
        self.navigationController.dismiss(animated: true, completion: nil)
    }
    
    func registerControllerDidCancel() {
        dlog("")
        self.navigationController.dismiss(animated: true, completion: nil)
    }
    
    func registerControllerDidError(error: NSError?) {
        dlog(String(describing: error))
        self.navigationController.dismiss(animated: true, completion: nil)
    }
    
    func registerControllerShouldBrowse(_ vc: RegisterViewController, WithAuthToken authToken: String) {
        
        let redirectUrlString = "?redirect_to=" + Constants.registerRedirectUrl
        let urlString = Constants.theMovieDbCreateAccountExternalUrl + authToken + redirectUrlString
        
        dlog("url string: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            dlog("url error: \(urlString)")
            return
        }
        let safari = SFSafariViewController(url: url)
        //let _ = safari.view  //hack around empty screen if sfvc is not root of nav
        safari.delegate = vc
        safari.modalTransitionStyle = .crossDissolve
        safari.modalPresentationStyle = .overFullScreen
        let sfRegisterModalNav = UINavigationController(rootViewController: safari)
        sfRegisterModalNav.setNavigationBarHidden(true, animated: false)
        vc.present(sfRegisterModalNav, animated: true, completion: nil)
        
    }
    
}

extension ProfileCoordinator {
    
}
