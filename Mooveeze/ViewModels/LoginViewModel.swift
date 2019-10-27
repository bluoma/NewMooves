//
//  LoginViewModel.swift
//  Mooveeze
//
//  Created by Bill on 9/9/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation
import UIKit

class LoginViewModel {
    
    var networkCallIsActive: Bool = false
    var userService = UserAccountService()
    var testUserService = TestUserService()
    
    fileprivate var userAuthWrapper: UserAuthViewModelWrapper = UserAuthViewModelWrapper()
    
    var dynamicUserAuth: DynamicUserAuth {
        return userAuthWrapper
    }
}

//MARK - Networl
extension LoginViewModel {
    
    
    func fetchTestUser(byId id: Int) {
        testUserService.fetchTestUser(withId: id) { (user: TestUser?, error: Error?) in
            
            if let err = error {
                dlog("error: \(String(describing: err))")
            }
            else {
                dlog("user: \(String(describing: user))")
            }
        }
    }
    
    func fetchAllTestUsers() {
        testUserService.fetchTestUsers( completion: { (users: [TestUser], error: Error?) in
            
            if let err = error {
                dlog("error: \(String(describing: err))")
            }
            else {
                dlog("users: \(String(describing: users))")
            }
        })
    }
    
    
    func fetchAuthToken() {
        
        if networkCallIsActive { return }
        userAuthWrapper.isLoginInProcess.value = true
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        networkCallIsActive = true
        
        userService.fetchAuthToken {
            [weak self] (token: String?, error: Error?) in
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
                assert(false, "error and token are nil")
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
        { [weak self] (validToken: String?, error: Error?) in
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
                assert(false, "error and token are nil")
            }
        })
    }
    
    func createSession() {
        
        
        if networkCallIsActive { return }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        networkCallIsActive = true
        let validatedAuthToken = userAuthWrapper.validatedAuthToken.value

        userService.createSession(withValidatedToken: validatedAuthToken, completion:
        { [weak self] (validSessionId: String?, error: Error?) in
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
                assert(false, "error and token are nil")
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
