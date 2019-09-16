//
//  DynamicMovieVideo.swift
//  Mooveeze
//
//  Created by Bill on 9/15/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import UIKit

protocol DynamicMovieVideo: class {
    
    var videoId: Dynamic<String> { get }
    var key: Dynamic<String>  { get }
    var name: Dynamic<String>  { get }
    var site: Dynamic<String>  { get }
    var size: Dynamic<Int>  { get }
    var type: Dynamic<String>  { get }
    var url: Dynamic<URL?> { get }
    
}

class MovieVideoViewModelWrapper: DynamicMovieVideo {
    
    let videoId: Dynamic<String>
    let key: Dynamic<String>
    let name: Dynamic<String>
    let site: Dynamic<String>
    let size: Dynamic<Int>
    let type: Dynamic<String>
    let url: Dynamic<URL?>
    
    init(movieVideo: MovieVideo) {
        
        videoId = Dynamic(movieVideo.videoId)
        key = Dynamic(movieVideo.key)
        name = Dynamic(movieVideo.name)
        site = Dynamic(movieVideo.site)
        size = Dynamic(movieVideo.size)
        type = Dynamic(movieVideo.type)
        if let videoUrl = MovieVideoViewModelWrapper.constructVideoUrl(from: movieVideo) {
            url = Dynamic(videoUrl)
        }
        else {
            dlog("error creating video url from model: \(movieVideo)")
            url = Dynamic(nil)
        }
    }
    
    static func constructVideoUrl(from video: MovieVideo) -> URL? {
        var url: URL? = nil
        
        if video.site == "YouTube" {
            let urlString = "https://www.youtube.com/watch?v=\(video.key)"
            url = URL(string: urlString)
        }
        
        return url
    }
}
