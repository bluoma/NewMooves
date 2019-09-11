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
    
    func updateLoginInProgress(_ isLoginInProcess: Bool) {
        self.isLoginInProcess.value = isLoginInProcess
    }
}

class LoginViewModel {
    
    var networkCallIsActive: Bool = false
    var userService = UserAccountService()
    
    fileprivate var userAuthWrapper: UserAuthViewWrapper = UserAuthViewWrapper()
    
    var dynamicUserAuth: DynamicUserAuth {
        return userAuthWrapper
    }
}

//MARK - Networl
extension LoginViewModel {
    func fetchAuthToken() {
        
        if networkCallIsActive { return }
        userAuthWrapper.isLoginInProcess.value = true
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        networkCallIsActive = true
        
        userService.fetchAuthToken {
            [weak self] (token: String?, error: NSError?) in
            guard let myself = self else { return }
            myself.networkCallIsActive = false
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            if let foundError = error {
                myself.userAuthWrapper.isLoginInProcess.value = false
                myself.userAuthWrapper.updateError(foundError)
            }
            else if let foundToken = token {
                myself.userAuthWrapper.updateAuthToken(foundToken)
                myself.validateAuthToken()
            }
            else {
                dlog("unknown error")
                myself.userAuthWrapper.isLoginInProcess.value = false
                myself.userAuthWrapper.updateLoginSuccess(false)
            }
        }
    }
    
    func validateAuthToken() {
        
        if networkCallIsActive { return }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        networkCallIsActive = true
        
        let authToken = userAuthWrapper.authToken.value
        let username = userAuthWrapper.username.value
        let password = userAuthWrapper.password.value
        
        userService.validateAuthToken(withAuthToken: authToken, username: username, password: password, completion:
        { [weak self] (validToken: String?, error: NSError?) in
            guard let myself = self else { return }
            myself.networkCallIsActive = false
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            if let foundError = error {
                myself.userAuthWrapper.isLoginInProcess.value = false
                myself.userAuthWrapper.updateError(foundError)
            }
            else if let foundToken = validToken {
                myself.userAuthWrapper.updateValidatedAuthToken(foundToken)
                myself.createSession()
            }
            else {
                dlog("unknown error")
                myself.userAuthWrapper.isLoginInProcess.value = false
                myself.userAuthWrapper.updateLoginSuccess(false)
            }
        })
    }
    
    func createSession() {
        
        
        if networkCallIsActive { return }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        networkCallIsActive = true
        let validatedAuthToken = userAuthWrapper.validatedAuthToken.value

        userService.createSession(withValidatedToken: validatedAuthToken, completion:
        { [weak self] (validSessionId: String?, error: NSError?) in
            guard let myself = self else { return }
            myself.networkCallIsActive = false
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            myself.userAuthWrapper.isLoginInProcess.value = false

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

//MARK: - validation
extension LoginViewModel {
    
    func textFieldsDidValidate() -> Bool {
        var userNameIsValid = false
        var passwordIsValid = false
        
        var usernameText = userAuthWrapper.username.value
        usernameText = usernameText.trimmingCharacters(in: .whitespaces)
        if usernameText.count >= 6 && usernameText.count <= 16 {
            userNameIsValid = true
        }
        else {
            userAuthWrapper.status.value = "Username length must be 6-16"
        }
        
        
        if !userNameIsValid { return false }
        
        var passwordText = userAuthWrapper.password.value
        passwordText = passwordText.trimmingCharacters(in: .whitespaces)
        if passwordText.count >= 6 && passwordText.count <= 16 {
            passwordIsValid = true
        }
        else {
            userAuthWrapper.status.value = "Password length must be 6-16"
        }
        
        return userNameIsValid && passwordIsValid
    }
}
