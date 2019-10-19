//
//  RegisterViewModel.swift
//  Mooveeze
//
//  Created by Bill on 9/17/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import UIKit


class RegisterViewModel {
    
    var networkCallIsActive: Bool = false
    var userService = UserAccountService()
    
    fileprivate var userAuthWrapper: UserAuthViewModelWrapper = UserAuthViewModelWrapper()
    
    var dynamicUserAuth: DynamicUserAuth {
        return userAuthWrapper
    }
    
}

//MARK - validation
extension RegisterViewModel {
    
    func didReceiveAuthCallback(withUrl url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) {
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems else {
                //error
            return
        }
            
        let tokenName = "request_token"
        var tokenVal = ""
        let statusName = "approved"
        var statusVal = ""
        
        for item in queryItems {
            if item.name == tokenName {
                tokenVal = item.value ?? ""
            }
            if item.name == statusName {
                statusVal = item.value ?? ""
            }
        }
        
        if !tokenVal.isEmpty && !statusVal.isEmpty {
            
            if statusVal == "true" && tokenVal == userAuthWrapper.authToken.value {
                userAuthWrapper.updateValidatedAuthToken(tokenVal)
            }
            else {
                //error
            }
        }
        else {
            //error
        }
    }
}

//MARK - Network
extension RegisterViewModel {
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
            }
            else {
                assert(false, "error and token are nil")
            }
        }
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
