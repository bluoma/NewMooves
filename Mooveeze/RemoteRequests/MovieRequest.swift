//
//  MovieRequest.swift
//  Mooveeze
//
//  Created by Bill on 10/18/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

public enum MovieListType: Int {
    case nowPlaying
    case topRated
}

class MovieRequest: JsonHttpRequest, CustomStringConvertible {
    
    override init() {
        super.init()
        super.version = "/3"
        super.resourcePath = "/movie"
    }
    
    class func fetchMovieListRequest(withType listType: MovieListType, page: Int) -> MovieRequest {
    
        let request = MovieRequest()
        request.method = HTTPMethod.get.rawValue
        
        switch listType {
            
        case .nowPlaying:
            request.appendPath("now_playing")
        case .topRated:
            request.appendPath("top_rated")
        }
        request.params["page"] = String(page)
        
        return request
    }
    
    class func fetchMoviewDetailRequest(withMovieId movieId: String) -> MovieRequest {
        
        let request = MovieRequest()
        request.method = HTTPMethod.get.rawValue
        request.appendPath(movieId)
        
        return request
    }
    
    
    class func fetchMovieVideosRequest(withMovieId movieId: String) -> MovieRequest {
        
        let request = MovieRequest()
        request.method = HTTPMethod.get.rawValue
        request.appendPath(movieId)
        request.appendPath("videos")
        
        return request
        
    }
    
    var description: String {
        return "MovieRequest"
    }
}
