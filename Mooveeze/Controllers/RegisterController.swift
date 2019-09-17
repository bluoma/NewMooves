//
//  RegisterController.swift
//  Mooveeze
//
//  Created by Bill on 9/17/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import UIKit
import SafariServices

class RegisterController: NSObject {

    var safari: SFSafariViewController!
    var registerDidSucceed: ((String) -> Void)?
    var registerDidErr: ((NSError?) -> Void)?
    var registerDidCancel: (() -> Void)?
    
    override init() {
        super.init()
        guard let url = URL(string: "https://www.google.com") else { return }
        
        safari = SFSafariViewController(url: url)
        safari.delegate = self
        
    }
    
}


extension RegisterController: SFSafariViewControllerDelegate {
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dlog("")
        self.registerDidSucceed?("")
    }
    
    func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {
        dlog("initialLoadDidRedirectTo: \(URL)")
    }
    
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        dlog("didLoadSuccessfully: \(didLoadSuccessfully)")
    }
    
    
}
