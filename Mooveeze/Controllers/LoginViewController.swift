//
//  MoviesLoginViewController.swift
//  Mooveeze
//
//  Created by Bill on 9/5/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import UIKit

//note Login VC can freeze when uitextfield becomes first responder due to ios13 simulator bug
//on simulator, do Edit->Automatically Sync Pasteboard to deselect, followed by Hardware->Restart
//see: https://forums.developer.apple.com/thread/122972

class LoginViewController: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var waitActivityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var usernameTextField: BindableTextField! {
        didSet {
            usernameTextField.bind {
                [unowned self] (usernameText: String) in
                self.dynamicUserAuth?.username.value = usernameText
                self.dynamicUserAuth?.status.value = ""
            }
        }
    }
    @IBOutlet weak var passwordTextField: BindableTextField! {
        didSet {
            passwordTextField.bind {
                [unowned self] (passwordText: String) in
                self.dynamicUserAuth?.password.value = passwordText
                self.dynamicUserAuth?.status.value = ""
            }
        }
    }
    
    //injected by coordinator
    var loginViewModel: LoginViewModel!
    var dynamicUserAuth: DynamicUserAuth? {
        
        didSet {
            guard let dynAuth = dynamicUserAuth else { return }
            
            dynAuth.username.bind {
                [unowned self] (username: String) in
                dlog("username fired: \(username)")
                if let text = self.usernameTextField.text, text != username {
                    self.usernameTextField.text = username
                }
            }
            dynAuth.password.bind {
                [unowned self] (password: String) in
                dlog("password fired: \(password)")
                if let text = self.passwordTextField.text, text != password {
                    self.passwordTextField.text = password
                }
            }
            dynAuth.status.bindAndFire {
                [unowned self] (status: String) in
                dlog("status fired: \(status)")
                self.statusLabel.text = status
            }
            dynAuth.error.bindAndFire {
                [unowned self] (error: Error?) in
                guard let error = error else { return }
                
                self.displayError(error)
            }
            dynAuth.sessionId.bindAndFire {
                [unowned self] (sessionId: String) in
                dlog("sessionId fired: \(sessionId)")
                if sessionId.count == 40 {
                    self.loginDidSucceed?(sessionId)
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
    
    var loginDidSucceed: ((String) -> Void)?
    var loginDidErr: ((NSError?) -> Void)?
    var loginDidCancel: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dynamicUserAuth = loginViewModel.dynamicUserAuth
        dlog("")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        dlog("")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

//MARK: - Actions
extension LoginViewController {
    @IBAction func donePressed(_ sender: UIBarButtonItem){
        dlog("")
        loginDidCancel?()
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        
        if loginViewModel.textFieldsDidValidate() {
            view.endEditing(true)
            loginViewModel.fetchAuthToken()
        }
    }
    
    func displayError(_ error: Error) {
        if error is ServiceError {
            let serviceError = error as! ServiceError
            dynamicUserAuth?.status.value = serviceError.msg
        }
        else {
            dynamicUserAuth?.status.value = error.localizedDescription
        }
    }
}





