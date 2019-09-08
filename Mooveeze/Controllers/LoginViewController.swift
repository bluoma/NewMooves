//
//  MoviesLoginViewController.swift
//  Mooveeze
//
//  Created by Bill on 9/5/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    enum TextFieldTag: Int {
        case username = 0
        case password = 1
    }
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var downloadIsInProgress: Bool = false
    var userService = UserAccountService()

    var authToken: String = ""
    var validatedAuthToken: String = ""
    var username: String = ""
    var password: String = ""
    
    var loginDidSucceed: ((String) -> Void)?
    var loginDidErr: ((NSError?) -> Void)?
    var loginDidCancel: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        usernameTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }

    func fetchAuthToken() {
        
        if downloadIsInProgress { return }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        downloadIsInProgress = true
        
        userService.fetchAuthToken { [weak self] (token: String?, error: NSError?) in
            
            guard let myself = self else { return }
            myself.downloadIsInProgress = false
            UIApplication.shared.isNetworkActivityIndicatorVisible = false

            if let foundError = error {
                myself.loginDidErr?(foundError)
            }
            else if let foundToken = token {
                myself.authToken = foundToken
                myself.validateAuthToken()
            }
            else {
                myself.loginDidErr?(nil)
            }
        }
    }
    
    func validateAuthToken() {
        
        if downloadIsInProgress { return }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        downloadIsInProgress = true
        
        userService.validateAuthToken(withAuthToken: authToken, username: username, password: password, completion:
        { [weak self] (validToken: String?, error: NSError?) in
            guard let myself = self else { return }
            myself.downloadIsInProgress = false
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            if let foundError = error {
                myself.statusLabel.text = foundError.localizedDescription
            }
            else if let foundToken = validToken {
                myself.validatedAuthToken = foundToken
                myself.createSession()
            }
            else {
                myself.statusLabel.text = "Login Error"
            }
            
        })
        
    }
    
    func createSession() {
        
        if downloadIsInProgress { return }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        downloadIsInProgress = true
        
        userService.createSession(withValidatedToken: validatedAuthToken, completion:
        { [weak self] (validSessionId: String?, error: NSError?) in
            guard let myself = self else { return }
            myself.downloadIsInProgress = false
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            if let foundError = error {
                myself.loginDidErr?(foundError)
            }
            else if let foundSessionId = validSessionId {
               myself.loginDidSucceed?(foundSessionId)
            }
            else {
                myself.loginDidErr?(nil)
            }
        })
    }
    
    @IBAction func donePressed(_ sender: UIBarButtonItem){
        dlog("")
        self.loginDidCancel?()
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        
        if textFieldsDidValidate() {
            
            self.fetchAuthToken()
        }
    }
    
    func textFieldsDidValidate() -> Bool {
        var userNameIsValid = false
        var passwordIsValid = false

        if var usernameText = usernameTextField.text {
            usernameText = usernameText.trimmingCharacters(in: .whitespaces)
            if usernameText.count >= 6 && usernameText.count <= 16 {
                userNameIsValid = true
                username = usernameText
            }
            else {
                statusLabel.text = "Username length must be 6-16"
            }
        }
        else {
            statusLabel.text = "Username length must be 6-16"
        }
        
        if !userNameIsValid { return false }
        
        if var passwordText = passwordTextField.text {
            passwordText = passwordText.trimmingCharacters(in: .whitespaces)
            if passwordText.count >= 6 && passwordText.count <= 16 {
                passwordIsValid = true
                password = passwordText
            }
            else {
                statusLabel.text = "Password length must be 6-16"
            }
        }
        else {
            statusLabel.text = "Password length must be 6-16"
        }
        
        return userNameIsValid && passwordIsValid
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if var text = textField.text {
            text += string
            if text.count >= 6 {
                statusLabel.text = "Status: Not Logged In"
            }
        }
        
        return true
    }
    
}
