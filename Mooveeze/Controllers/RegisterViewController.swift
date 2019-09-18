//
//  RegisterViewController.swift
//  Mooveeze
//
//  Created by Bill on 9/17/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import UIKit
import SafariServices

class RegisterViewController: UIViewController {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var waitActivityIndicatorView: UIActivityIndicatorView!
    
    var registerShouldBrowse: ((RegisterViewController, String) -> Void)?
    var registerDidSucceed: ((String) -> Void)?
    var registerDidErr: ((NSError?) -> Void)?
    var registerDidCancel: (() -> Void)?
    var didPresentSafari = false
    
    //injected by coordinator
    var registerViewModel: RegisterViewModel!
    var dynamicUserAuth: DynamicUserAuth? {
        
        didSet {
            guard let dynAuth = dynamicUserAuth else { return }
            
            dynAuth.status.bindAndFire {
                [unowned self] (status: String) in
                dlog("status fired: \(status)")
                self.statusLabel.text = status
            }
            dynAuth.error.bindAndFire {
                [unowned self] (error: Error?) in
                guard let error = error else { return }
                dlog("error: \(error)")
                self.displayError(error)
            }
            dynAuth.authToken.bind {
                [unowned self] (authToken: String) in
                dlog("authToken fired: \(authToken)")
                self.registerShouldBrowse?(self, authToken)
            }
            dynAuth.validatedAuthToken.bind {
                [unowned self] (validatedAuthToken: String) in
                dlog("validatedAuthToken fired: \(validatedAuthToken)")
                self.registerViewModel.createSession()
            }
            dynAuth.sessionId.bind {
                [unowned self] (sessionId: String) in
                dlog("sessionId fired: \(sessionId)")
                if sessionId.count == 40 {
                    self.registerDidSucceed?(sessionId)
                }
                else {
                    //error
                }
            }
            dynAuth.isLoginInProcess.bindAndFire {
                [unowned self] (isLoginInProcess: Bool) in
                dlog("isLoginInProcess fired: \(isLoginInProcess)")
                if isLoginInProcess {
                    self.waitActivityIndicatorView.startAnimating()
                }
                else {
                    self.waitActivityIndicatorView.stopAnimating()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dynamicUserAuth = registerViewModel.dynamicUserAuth
        
        let notifName = Notification.Name(rawValue: Constants.registerNotification)
        NotificationCenter.default.addObserver(self, selector: #selector(handleRegisterNotification(_:)), name: notifName, object: nil)
        
        registerViewModel.fetchAuthToken()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    @objc func handleRegisterNotification(_ notif: NSNotification) {
        dlog("notif: \(notif)")
        
        //sfsafari
        self.dismiss(animated: true, completion: nil)
        
        if let url = notif.object as? URL {
            registerViewModel.didReceiveAuthCallback(withUrl: url)
        }
        else {
            //error
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /*
    fileprivate func displaySafariViewController(withToken authToken: String) {
        
        let redirectUrlString = "?redirect_to=" + Constants.registerRedirectUrl
        let urlString = Constants.theMovieDbCreateAccountExternalUrl + authToken + redirectUrlString
        
        dlog("url string: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            dlog("url error: \(urlString)")
            return
        }
        let safari = SFSafariViewController(url: url)
        let _ = safari.view  //hack around empty screen
        safari.delegate = self
        safari.modalTransitionStyle = .crossDissolve
        safari.modalPresentationStyle = .overCurrentContext
        self.present(safari, animated: true, completion: nil)
        
    }
    */
    
    fileprivate func displayError(_ error: Error) {
        if error is ServiceError {
            let serviceError = error as! ServiceError
            dynamicUserAuth?.status.value = serviceError.msg
        }
        else {
            dynamicUserAuth?.status.value = error.localizedDescription
        }
    }
}


extension RegisterViewController: SFSafariViewControllerDelegate {
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dlog("")
        self.registerDidCancel?()
    }
    
    func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {
        dlog("initialLoadDidRedirectTo: \(URL)")
    }
    
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        dlog("didLoadSuccessfully: \(didLoadSuccessfully)")
    }
    
    
}
