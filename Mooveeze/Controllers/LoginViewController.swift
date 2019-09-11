//
//  MoviesLoginViewController.swift
//  Mooveeze
//
//  Created by Bill on 9/5/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import UIKit

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
    
    var loginViewModel: LoginViewModel = LoginViewModel()
    var dynamicUserAuth: DynamicUserAuth? {
        
        didSet {
            guard let dynAuth = dynamicUserAuth else { return }
            
            dynAuth.username.bindAndFire {
                [unowned self] (username: String) in
                dlog("username fired: \(username)")
                if let text = self.usernameTextField.text, text != username {
                    self.usernameTextField.text = username
                }
            }
            dynAuth.password.bindAndFire {
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
                [unowned self] (error: NSError?) in
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        usernameTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
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
    
    func displayError(_ error: NSError) {
        dynamicUserAuth?.status.value = error.localizedDescription
    }
}




