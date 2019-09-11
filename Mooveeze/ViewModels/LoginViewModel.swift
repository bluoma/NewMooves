//
//  LoginViewModel.swift
//  Mooveeze
//
//  Created by Bill on 9/9/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation
import UIKit

protocol DynamicUserAuth {
    //auth fields
    var authToken: Dynamic<String> { get }
    var username: Dynamic<String> { get }
    var password: Dynamic<String> { get }
    var validatedAuthToken: Dynamic<String> { get }
    var sessionId: Dynamic<String> { get }
    var status: Dynamic<String> { get }
    var loginSuccess: Dynamic<Bool> { get }
    var error: Dynamic<NSError?> { get }
    //view state
    var isLoginInProcess: Dynamic<Bool> { get }
    
}

fileprivate class UserAuthViewWrapper: DynamicUserAuth {
    
    var authToken: Dynamic<String>
    var username: Dynamic<String>
    var password: Dynamic<String>
    var validatedAuthToken: Dynamic<String>
    var sessionId: Dynamic<String>
    var status: Dynamic<String>
    var loginSuccess: Dynamic<Bool>
    var error: Dynamic<NSError?>

    //view state
    var isLoginInProcess: Dynamic<Bool>
    
    init() {
        authToken = Dynamic("")
        username = Dynamic("")
        password = Dynamic("")
        validatedAuthToken = Dynamic("")
        sessionId = Dynamic("")
        status = Dynamic("Not logged in")
        error = Dynamic(nil)
        loginSuccess = Dynamic(false)

        isLoginInProcess = Dynamic(false)
        
    }
    
    func updateAuthToken(_ authToken: String) {
        self.authToken.value = authToken
    }
    
    func updateValidatedAuthToken(_ validatedAuthToken: String) {
        self.validatedAuthToken.value = validatedAuthToken
    }
    
    func updateSessionId(_ sessionId: String) {
        self.sessionId.value = sessionId
    }
    
    func updateLoginSuccess(_ success: Bool) {
        self.loginSuccess.value = success
    }
    
    func updateError(_ error: NSError?) {
        self.error.value = error
    }
    
}

class LoginViewModel {
    
    /*
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
    */
    
    var downloadIsInProgress: Bool = false
    var userService = UserAccountService()
    
    fileprivate var userAuthWrapper: UserAuthViewWrapper = UserAuthViewWrapper()
    
    var dynamicUserAuth: DynamicUserAuth {
        return userAuthWrapper
    }
}

//MARK - Networl
extension LoginViewModel {
    func fetchAuthToken() {
        
        if downloadIsInProgress { return }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        downloadIsInProgress = true
        
        userService.fetchAuthToken {
            [weak self] (token: String?, error: NSError?) in
            guard let myself = self else { return }
            myself.downloadIsInProgress = false
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            if let foundError = error {
                myself.userAuthWrapper.updateError(foundError)
            }
            else if let foundToken = token {
                myself.userAuthWrapper.updateAuthToken(foundToken)
                myself.validateAuthToken()
            }
            else {
                dlog("unknown error")
                myself.userAuthWrapper.updateLoginSuccess(false)
            }
        }
    }
    
    func validateAuthToken() {
        
        if downloadIsInProgress { return }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        downloadIsInProgress = true
        
        let authToken = userAuthWrapper.authToken.value
        let username = userAuthWrapper.username.value
        let password = userAuthWrapper.password.value
        
        userService.validateAuthToken(withAuthToken: authToken, username: username, password: password, completion:
        { [weak self] (validToken: String?, error: NSError?) in
            guard let myself = self else { return }
            myself.downloadIsInProgress = false
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            if let foundError = error {
                myself.userAuthWrapper.updateError(foundError)
            }
            else if let foundToken = validToken {
                myself.userAuthWrapper.updateValidatedAuthToken(foundToken)
                myself.createSession()
            }
            else {
                dlog("unknown error")
                myself.userAuthWrapper.updateLoginSuccess(false)
            }
        })
    }
    
    func createSession() {
        
        
        if downloadIsInProgress { return }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        downloadIsInProgress = true
        let validatedAuthToken = userAuthWrapper.validatedAuthToken.value

        userService.createSession(withValidatedToken: validatedAuthToken, completion:
        { [weak self] (validSessionId: String?, error: NSError?) in
            guard let myself = self else { return }
            myself.downloadIsInProgress = false
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            if let foundError = error {
                myself.userAuthWrapper.updateError(foundError)
            }
            else if let foundSessionId = validSessionId {
                myself.userAuthWrapper.updateSessionId(foundSessionId)
            }
            else {
                dlog("unknown error")
                myself.userAuthWrapper.updateLoginSuccess(false)
            }
        })
        
    }
    
}
