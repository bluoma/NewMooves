//
//  ProfileViewController.swift
//  Mooveeze
//
//  Created by Bill on 9/5/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var emptyStateView: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    
    var httpClient = UserAccountHttpClient()
    var downloadIsInProgress: Bool = false
    var endpointPath: String = theMovieDbProfilePath
    var userProfile: UserProfile?
    
    var didSelectLogin: (() -> Void)?
    var didSelectCreateAccount: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if sessionId == nil {
            self.emptyStateView.isHidden = false
        }
        else {
            self.emptyStateView.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        dlog("")
        if let foundSessionId = sessionId, userProfile == nil {
            dlog("foundSessionId: \(foundSessionId), getAccount")
            fetchUserProfile()
        }
    }
    
    //MARK: - Network
    func fetchUserProfile() {
        guard let foundSessionId = sessionId else { return }
        if downloadIsInProgress { return }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let params: [String: AnyObject] = ["sessionId": foundSessionId as AnyObject]
        
        httpClient.fetchUserProfile(params: params, completion:
        { [weak self] (profile: UserProfile?, error: NSError?) -> Void in
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            guard let strongself = self else { return }
            
            if error != nil {
                dlog("err: \(String(describing: error))")
            }
            else if let foundProfile = profile {
                dlog("profile: \(foundProfile)")
                strongself.userProfile = foundProfile
                strongself.title = foundProfile.username
                strongself.emptyStateView.isHidden = true
            }
            else {
                dlog("no error, no profile...?")
            }
        })
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        dlog("")
        self.didSelectLogin?()
    }
    
    @IBAction func createAccountPressed(_ sender: UIButton) {
        dlog("")
        self.didSelectCreateAccount?()
    }
}
