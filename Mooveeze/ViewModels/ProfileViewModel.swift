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
/*
 let avatar: Avatar
 let profileId: Int
 let language: String
 let region: String
 let fullname: String
 let includeAdult: Bool
 let username: String
 */
protocol DynamicUserProfile {
    //profile object
    var profileId: Dynamic<Int> { get }
    var username: Dynamic<String> { get }
    var fullname: Dynamic<String> { get }
    var userAvatar: Dynamic<UIImage?> { get }
    //view state
    var isProfileLoading: Dynamic<Bool> { get }
    var isEmptyState: Dynamic<Bool> { get }
    
    func resetProfile()
}

fileprivate class UserProfileViewWrapper: DynamicUserProfile {
   
    //profile object
    var profileId: Dynamic<Int>
    var username: Dynamic<String>
    var fullname: Dynamic<String>
    var userAvatar: Dynamic<UIImage?>
    //view state
    var isProfileLoading: Dynamic<Bool>
    var isEmptyState: Dynamic<Bool>
    
    init(_ profile: UserProfile? = nil) {
        let defaultImage = UIImage(named: "profile_icon")
        if let profile = profile {
            profileId = Dynamic(profile.profileId)
            username = Dynamic(profile.username)
            fullname = Dynamic(profile.fullname)
            userAvatar = Dynamic(defaultImage)
            isProfileLoading = Dynamic(false)
            isEmptyState = Dynamic(false)
        }
        else {
            profileId = Dynamic(-1)
            username = Dynamic("")
            fullname = Dynamic("")
            userAvatar = Dynamic(defaultImage)
            isProfileLoading = Dynamic(false)
            isEmptyState = Dynamic(false)
        }
    }
    
    func resetProfile() {
        let defaultImage = UIImage(named: "profile_icon")
        profileId.value = -1
        username.value = ""
        fullname.value = ""
        userAvatar.value = defaultImage
        isProfileLoading.value = false
        isEmptyState.value = true
    }
    
    func updateProfile(_ profile: UserProfile) {
        updateProfileId(profile.profileId)
        updateProfileUsername(profile.username)
        updateProfileFullname(profile.fullname)
    }
    
    func updateProfileId(_ profileId: Int) {
        self.profileId.value = profileId
    }
    
    func updateProfileUsername(_ username: String) {
        self.username.value = username
    }
    
    func updateProfileFullname(_ fullname: String) {
        self.fullname.value = fullname
    }
    
    func updateProfileImage(_ image: UIImage) {
        self.userAvatar.value = image
    }
    
    func updateProfileIsLoading(_ isLoading: Bool) {
        self.isProfileLoading.value = isLoading
    }
    
    func updateProfileIsEmptyState(_ isEmptyState: Bool) {
        self.isEmptyState.value = isEmptyState
    }
}

class ProfileViewModel {
    
    
    /*
     @IBOutlet weak var statusLabel: UILabel!
     @IBOutlet weak var emptyStateView: UIView!
     @IBOutlet weak var loginButton: UIButton!
     @IBOutlet weak var createAccountButton: UIButton!
     @IBOutlet weak var profileContainer: UIView!
     @IBOutlet weak var userAvatar: UIImageView!
     @IBOutlet weak var usernameLabel: UILabel!
    */
    
    fileprivate var userService = UserAccountService()
    fileprivate var downloadIsInProgress: Bool = false
    fileprivate var userProfile: UserProfile?
    fileprivate var userProfileWrapper: UserProfileViewWrapper = UserProfileViewWrapper()
    
    var dynamicUserProfile: DynamicUserProfile {
        get {
            return userProfileWrapper
        }
    }
    
    fileprivate func updateDynamicProfile(profile: UserProfile) {
        self.userProfile = profile
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
        { [weak self] (profile: UserProfile?, error: NSError?) -> Void in
            
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
                dlog("no error, no profile...?")
                myself.userProfileWrapper.updateProfileIsLoading(false)
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
}
