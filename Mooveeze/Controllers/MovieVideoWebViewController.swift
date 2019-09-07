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

    var movie: Movie!
    var videoIndex: Int = 0
    @IBOutlet var videoWebView: WKWebView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !movie.movieVideos.isEmpty
        {
            let video = movie.movieVideos[videoIndex]
            if let vurl = self.constructVideoUrl(from: video)
            {
                self.videoWebView.load(URLRequest(url: vurl))
            }
        }
    }
    
    fileprivate func constructVideoUrl(from video: MovieVideo) -> URL? {
        var url: URL? = nil
        
        if video.site == "YouTube" {
            let urlString = "https://www.youtube.com/watch?v=\(video.key)"
            url = URL(string: urlString)
        }
        
        return url
    }

}
