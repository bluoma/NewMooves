//
//  VideoWebViewController.swift
//  Mooveeze
//
//  Created by Bill on 8/9/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import UIKit
import WebKit



class MovieVideoWebViewController: UIViewController {

    @IBOutlet var videoWebView: WKWebView!

    //injected by coordinator
    var videoViewModel: MovieVideoViewModel!
    
    var dynamicMovieVideo: DynamicMovieVideo? {
     
        didSet {
            dynamicMovieVideo?.url.bindAndFire {
                [unowned self] (url: URL?) in
                if let vurl = url {
                    let request = URLRequest(url: vurl)
                    self.videoWebView.load(request)
                }
                else {
                    dlog("no url")
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dynamicMovieVideo = videoViewModel.dynamicMovieVideo
        
    }
}
