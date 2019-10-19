//
//  DynamicUserAuth.swift
//  Mooveeze
//
//  Created by Bill on 9/15/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import UIKit

protocol DynamicUserAuth: class {
    //auth fields
    var authToken: Dynamic<String> { get }
    var username: Dynamic<String> { get }
    var password: Dynamic<String> { get }
    var validatedAuthToken: Dynamic<String> { get }
    var sessionId: Dynamic<String> { get }
    var status: Dynamic<String> { get }
    var loginSuccess: Dynamic<Bool> { get }
    var error: Dynamic<Error?> { get }
    var redirectUrl: Dynamic<URL?> { get }
    //view state
    var isLoginInProcess: Dynamic<Bool> { get }
    
}

class UserAuthViewModelWrapper: DynamicUserAuth {
    
    var authToken: Dynamic<String>
    var username: Dynamic<String>
    var password: Dynamic<String>
    var validatedAuthToken: Dynamic<String>
    var sessionId: Dynamic<String>
    var status: Dynamic<String>
    var loginSuccess: Dynamic<Bool>
    var error: Dynamic<Error?>
    var redirectUrl: Dynamic<URL?>
    
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
        redirectUrl = Dynamic(nil)
        
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
    
    func updateError(_ error: Error?) {
        self.error.value = error
    }
    
    func updateLoginInProgress(_ isLoginInProcess: Bool) {
        self.isLoginInProcess.value = isLoginInProcess
    }
    
    func updateRedirectUrl(_ redirectUrl: URL) {
        self.redirectUrl.value = redirectUrl
    }
}
