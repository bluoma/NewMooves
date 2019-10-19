//
//  DynamicUserProfile.swift
//  Mooveeze
//
//  Created by Bill on 9/15/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import UIKit


protocol DynamicUserProfile: class {
    //profile object
    var profileId: Dynamic<Int> { get }
    var username: Dynamic<String> { get }
    var fullname: Dynamic<String> { get }
    var userAvatar: Dynamic<UIImage?> { get }
    //view state
    var isProfileLoading: Dynamic<Bool> { get }
    var isEmptyState: Dynamic<Bool> { get }
    var logoutDidComplete: Dynamic<Bool> { get }
    
    func resetProfile()
}

class UserProfileViewModelWrapper: DynamicUserProfile {
    
    //profile object
    let profileId: Dynamic<Int>
    let username: Dynamic<String>
    let fullname: Dynamic<String>
    let userAvatar: Dynamic<UIImage?>
    //view state
    let isProfileLoading: Dynamic<Bool>
    let isEmptyState: Dynamic<Bool>
    let logoutDidComplete: Dynamic<Bool>
    
    init(profile: UserProfile?) {
        let defaultImage = UIImage(named: "profile_icon")
        if let profile = profile {
            profileId = Dynamic(profile.profileId)
            username = Dynamic(profile.username)
            fullname = Dynamic(profile.fullname)
            userAvatar = Dynamic(defaultImage)
            isProfileLoading = Dynamic(false)
            isEmptyState = Dynamic(false)
            logoutDidComplete = Dynamic(false)
        }
        else {
            profileId = Dynamic(-1)
            username = Dynamic("")
            fullname = Dynamic("")
            userAvatar = Dynamic(defaultImage)
            isProfileLoading = Dynamic(false)
            isEmptyState = Dynamic(false)
            logoutDidComplete = Dynamic(false)
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
