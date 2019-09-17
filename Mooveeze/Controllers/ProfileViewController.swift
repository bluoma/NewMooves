//
//  ProfileViewController.swift
//  Mooveeze
//
//  Created by Bill on 9/5/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class ProfileViewController: UIViewController {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var emptyStateView: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var profileContainer: UIView!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var loadingActivityIndicatorView: UIActivityIndicatorView!
    
    //injected by coordinator
    var profileViewModel: ProfileViewModel!
    var dynamicUserProfile: DynamicUserProfile? {
        
        didSet {
            
            guard let dynProfile = dynamicUserProfile else {
                dlog("got nil for newValue")
                return
            }
            
            dynProfile.username.bindAndFire {
                [unowned self] (username: String) in
                dlog("username bindAndFire: \(username)")
                self.usernameLabel.text = username
                if username.count > 0 {
                    self.title = username
                }
                else {
                    self.title = "Profile"
                }
            }
            dynProfile.userAvatar.bindAndFire {
                [unowned self] (image: UIImage?) in
                dlog("userAvatar.bindAndFire\(String(describing: image))")
                self.userAvatar.alpha = 0.0;
                self.userAvatar.image = image
                UIView.animate(withDuration: 0.3, animations:
                { () -> Void in
                    self.userAvatar.alpha = 1.0
                })
            }
            dynProfile.isProfileLoading.bindAndFire {
                [unowned self] (isProfileLoading: Bool) in
                dlog("isProfileLoading.bindAndFire: \(isProfileLoading)")
                if isProfileLoading {
                    self.loadingActivityIndicatorView.startAnimating()
                }
                else {
                   self.loadingActivityIndicatorView.stopAnimating()
                }
            }
            dynProfile.isEmptyState.bindAndFire {
                [unowned self] (isEmptyState: Bool) in
                dlog("isEmptyState: \(isEmptyState)")
                if isEmptyState {
                    self.emptyStateView.isHidden = false
                    self.profileContainer.isHidden = true
                }
                else {
                    self.emptyStateView.isHidden = true
                    self.profileContainer.isHidden = false
                }
            }
            dynProfile.logoutDidComplete.bind {
                [unowned self] (didComplete: Bool) in
                dlog("logoutDidComplete: \(didComplete)")
                if let seshId = Constants.sessionId {
                    deleteSessionId(seshId)
                }
            }
        }
    }
    
    var didSelectLogin: (() -> Void)?
    var didSelectCreateAccount: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dynamicUserProfile = profileViewModel.dynamicUserProfile
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Constants.sessionId == nil {
            dynamicUserProfile?.isEmptyState.value = true
        }
        else {
            dynamicUserProfile?.isEmptyState.value = false
            self.profileViewModel.fetchUserProfile()
        }
    }
    
    //MARK: - Actions
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        dlog("")
        self.didSelectLogin?()
    }
    
    @IBAction func createAccountPressed(_ sender: UIButton) {
        dlog("")
        self.didSelectCreateAccount?()
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        dlog("")
        if let _ = Constants.sessionId {
            profileViewModel.deleteSession()
        }
    }
    
}
