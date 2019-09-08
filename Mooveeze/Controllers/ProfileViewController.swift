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
    
    var userService = UserAccountService()
    var downloadIsInProgress: Bool = false
    var userProfile: UserProfile?
    
    var didSelectLogin: (() -> Void)?
    var didSelectCreateAccount: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if Constants.sessionId == nil {
            emptyStateView.isHidden = false
            profileContainer.isHidden = true
        }
        else {
            emptyStateView.isHidden = true
            profileContainer.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        dlog("")
        if let foundSessionId = Constants.sessionId, userProfile == nil {
            dlog("foundSessionId: \(foundSessionId), getAccount")
            fetchUserProfile()
        }
    }
    
    //MARK: - Network
    func fetchUserProfile() {
        guard let foundSessionId = Constants.sessionId else { return }
        if downloadIsInProgress { return }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        userService.fetchUserProfile(withSessionId: foundSessionId, completion:
        { [weak self] (profile: UserProfile?, error: NSError?) -> Void in
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            guard let myself = self else { return }
            
            if error != nil {
                dlog("err: \(String(describing: error))")
            }
            else if let foundProfile = profile {
                dlog("profile: \(foundProfile)")
                myself.userProfile = foundProfile
                myself.title = foundProfile.username
                myself.emptyStateView.isHidden = true
                myself.emptyStateView.isHidden = false
                myself.updateProfileContainer()
            }
            else {
                dlog("no error, no profile...?")
            }
        })
    }
    
    fileprivate func updateProfileContainer() {
        self.usernameLabel.text = userProfile?.username
        guard let grId = userProfile?.avatar.gravatar else { return }
        fetchUserGravatar(with: grId.hash)
    }
    
    fileprivate func fetchUserGravatar(with grId: String) {
        
        //https://secure.gravatar.com/avatar/568ca559077995e89a812dff68afc914.jpg?s=150
        
        let imageUrlString = Constants.gravatarBaseUrl + "/" + grId + ".png?s=75"
        if let imageUrl = URL(string: imageUrlString) {
            let defaultImage = UIImage(named: "profile_icon")
            let urlRequest: URLRequest = URLRequest(url:imageUrl)
            
            userAvatar.af_setImage(
                withURLRequest: urlRequest,
                placeholderImage: defaultImage,
                completion:
                { [weak self] (response: DataResponse<UIImage>) in
                    guard let myself = self else { return }
                    dlog("got imagewrapper: \(type(of: response)), response: \(response) for url: \n\(imageUrlString)")
                    
                    if let image: UIImage = response.value
                    {
                        myself.userAvatar.alpha = 0.0;
                        myself.userAvatar.image = image
                        UIView.animate(withDuration: 0.3, animations:
                            { () -> Void in
                                myself.userAvatar.alpha = 1.0
                        })
                    }
                    else {
                        dlog("response is not a uiimage")
                    }
            })
        }
        else {
            dlog("bad url for image: \(imageUrlString)")
            let defaultImage = UIImage(named: "profile_icon")
            self.userAvatar.image = defaultImage
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
}
