//
//  VideoViewModel.swift
//  Mooveeze
//
//  Created by Bill on 9/13/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

class MovieVideoViewModel {
    
    fileprivate let movieVideo: MovieVideo
    fileprivate let viewModelWrapper: MovieVideoViewModelWrapper
    
    var dynamicMovieVideo: DynamicMovieVideo {
        return viewModelWrapper
    }
    
    init(movieVideo: MovieVideo) {
        self.movieVideo = movieVideo
        viewModelWrapper = MovieVideoViewModelWrapper(movieVideo: movieVideo)
    }
    
}

