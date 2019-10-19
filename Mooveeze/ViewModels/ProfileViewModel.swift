//
//  ProfileViewModel.swift
//  Mooveeze
//
//  Created by Bill on 9/5/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class ProfileViewModel {
    
    fileprivate var userService = UserAccountService()
    fileprivate var downloadIsInProgress: Bool = false
    fileprivate var userProfileWrapper: UserProfileViewModelWrapper = UserProfileViewModelWrapper(profile: nil)
    
    var dynamicUserProfile: DynamicUserProfile {
        get {
            return userProfileWrapper
        }
    }
    
    fileprivate func updateDynamicProfile(profile: UserProfile) {
        userProfileWrapper.updateProfile(profile)
        let grId = profile.avatar.gravatar.hash
        fetchUserGravatar(with: grId)
    }
    
}

//MARK: - Network
extension ProfileViewModel {
    
    func fetchUserProfile() {
        guard let foundSessionId = Constants.sessionId else { return }
        if downloadIsInProgress { return }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        userProfileWrapper.updateProfileIsLoading(true)
        userService.fetchUserProfile(withSessionId: foundSessionId, completion:
        { [weak self] (profile: UserProfile?, error: Error?) -> Void in
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            guard let myself = self else { return }
            
            if error != nil {
                dlog("err: \(String(describing: error))")
                myself.userProfileWrapper.updateProfileIsLoading(false)
            }
            else if let foundProfile = profile {
                dlog("profile: \(foundProfile)")
                myself.updateDynamicProfile(profile: foundProfile)
            }
            else {
                 assert(false, "error and profile are nil")
            }
        })
    }
    
    fileprivate func fetchUserGravatar(with grId: String) {
        
        //https://secure.gravatar.com/avatar/568ca559077995e89a812dff68afc914.jpg?s=150
        
        let imageUrlString = Constants.gravatarBaseUrl + "/" + grId + ".png?s=75"
        if let imageUrl = URL(string: imageUrlString) {
            let urlRequest: URLRequest = URLRequest(url: imageUrl)
            
            ImageDownloader.default.download(urlRequest)
            { [weak self] (response: DataResponse<UIImage>) in
                guard let myself = self else { return }
                
                myself.userProfileWrapper.updateProfileIsLoading(false)
                
                if let image: UIImage = response.value {
                    myself.userProfileWrapper.updateProfileImage(image)
                }
                else {
                    dlog("response is not a uiimage")
                }
            }
        }
        else {
            dlog("bad url for image: \(imageUrlString)")
            userProfileWrapper.updateProfileIsLoading(false)
        }
    }
    
    
    func deleteSession() {
        
        if downloadIsInProgress { return }
        guard let seshId = Constants.sessionId else { return }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        userService.deleteSession(seshId, completion:
        { [weak self] (success: Bool, error: Error?) in
            guard let myself = self else { return }
            myself.downloadIsInProgress = false
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            if let foundError = error {
                dlog("error logging out: \(foundError)")
                myself.userProfileWrapper.logoutDidComplete.value = false
            }
            else if success {
                myself.userProfileWrapper.logoutDidComplete.value = true
            }
            else {
                assert(false, "error and return are nil")
            }
            DispatchQueue.main.async {
                myself.userProfileWrapper.resetProfile()
            }
        })
        
    }
}
