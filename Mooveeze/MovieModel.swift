//
//  MovieSummaryDTO.swift
//  Mooveeze
//
//  Created by Bill on 10/7/16.
//  Copyright © 2016 Bill. All rights reserved.
//

import UIKit

class MovieDetail: CustomStringConvertible, CustomDebugStringConvertible {
    
    
    var tagline: String = ""
    var runtime: Int = 0
    var homepage: String = ""
    var genres: [String] = []
    
    
    init() {
        
    }
    
    convenience init(jsonDict: NSDictionary) {
        self.init()
    
        if let runtime = jsonDict["runtime"] as? Int {
            self.runtime = runtime
        }
        if let tagline = jsonDict["tagline"] as? String {
            self.tagline = tagline
        }
        if let homepage = jsonDict["homepage"] as? String {
            self.homepage = homepage
        }
        if let genres = jsonDict["genres"] as? [[String:AnyObject]] {
            for genre in genres {
                
                if let genreName = genre["name"] as? String {
                    self.genres.append(genreName)
                }
            }
        }
    }

    
    var description: String {
        return "tagline: \(tagline), runningTime: \(runtime), genres: \(genres), homepage: \(homepage)"
    }
    
    var debugDescription: String {
        return "tagline: \(tagline), runningTime: \(runtime), genres: \(genres), homepage: \(homepage)"
    }

}

class MovieVideo: CustomStringConvertible, CustomDebugStringConvertible {
    
    var videoId: String = ""
    var language: String = "en" //"iso_639_1"
    var region: String = "US"   //"iso_3166_1"
    var key: String = ""
    var name: String = ""
    var site: String = ""
    var size: Int = -1
    var type: String = "Trailer"
    
    
    init() {
        
    }
    
    convenience init(jsonDict: NSDictionary) {
        self.init()
        
        if let videoId = jsonDict["id"] as? String {
            self.videoId = videoId
        }
        if let language = jsonDict["iso_639_1"] as? String {
            self.language = language
        }
        if let region = jsonDict["iso_3166_1"] as? String {
            self.region = region
        }
        if let key = jsonDict["key"] as? String {
            self.key = key
        }
        if let name = jsonDict["name"] as? String {
            self.name = name
        }
        if let site = jsonDict["site"] as? String {
            self.site = site
        }
        if let size = jsonDict["size"] as? Int {
            self.size = size
        }
        if let type = jsonDict["type"] as? String {
            self.type = type
        }
       
    }
    
    
    var description: String {
        return "site: \(site), key: \(key), name: \(name)"
    }
    
    var debugDescription: String {
        return "site: \(site), key: \(key), name: \(name)"
    }
    
}

class MovieSummary: CustomStringConvertible, CustomDebugStringConvertible {

    var movieId: Int = -1
    var title: String = ""
    var adult: Bool = false
    var overview: String = ""
    var releaseDateString: String = ""
    var releaseDate: Date?
    var genreIds: [Int] = []
    var originalTitle: String = ""
    var originalLanguage: String = ""
    var posterPath: String = ""
    var backdropPath: String = ""
    var popularity: Double = 0.0
    var voteCount: Int = 0
    var video: Bool = false
    var voteAverage: Double = 0.0
    var movieDetail: MovieDetail? = nil
    var movieVideos: [MovieVideo] = []
    var dateFormatter = DateFormatter()
    
    init() {
        dateFormatter.dateFormat = "YYYY-MM-dd"
    }
    
    convenience init(jsonDict: NSDictionary) {
        self.init()
        
        //dlog("jsonDict: \(jsonDict)")
        
        if let movieId = jsonDict["id"] as? Int {
            self.movieId = movieId
        }
        if let title = jsonDict["title"] as? String {
            self.title = title
        }
        if let adult = jsonDict["adult"] as? String {
            self.adult = NSString(string: adult).boolValue
        }
        if let overview = jsonDict["overview"] as? String {
            self.overview = overview
        }
        if let releaseDate = jsonDict["release_date"] as? String {
            self.releaseDateString = releaseDate
            self.releaseDate = dateFormatter.date(from: releaseDateString)
        }
        if let genreIds = jsonDict["genre_ids"] as? [Int] {
            self.genreIds = genreIds
        }
        if let originalTitle = jsonDict["original_title"] as? String {
            self.originalTitle = originalTitle
        }
        if let originalLanguage = jsonDict["original_language"] as? String {
            self.originalLanguage = originalLanguage
        }
        if let posterPath = jsonDict["poster_path"] as? String {
            self.posterPath = posterPath
        }
        if let backdropPath = jsonDict["backdrop_path"] as? String {
            self.backdropPath = backdropPath
        }
        if let popularity = jsonDict["popularity"] as? Double {
            self.popularity = popularity
        }
        if let voteCount = jsonDict["vote_count"] as? Int {
            self.voteCount = voteCount
        }
        if let video = jsonDict["video"] as? String {
            self.video = NSString(string: video).boolValue
        }
        if let voteAverage = jsonDict["vote_average"] as? Double {
            self.voteAverage = voteAverage
        }
        
    }
    
    var description: String {
        return "id: \(movieId), title: \(title), postePath: \(posterPath), backdropPath: \(backdropPath), overview: \(overview)"
    }
    
    var debugDescription: String {
        
        return "id: \(movieId), title: \(title), postePath: \(posterPath), backdropPath: \(backdropPath), overview: \(overview)"
    }
    
}


/*
 
 
{
    "poster_path": "\/z6BP8yLwck8mN9dtdYKkZ4XGa3D.jpg",
    "adult": false,
    "overview": "A big screen remake of John Sturges' classic western The Magnificent Seven, itself a remake of Akira Kurosawa's Seven Samurai. Seven gun men in the old west gradually come together to help a poor village against savage thieves.",
    "release_date": "2016-09-14",
    "genre_ids": [28, 12, 37],
    "id": 333484,
    "original_title": "The Magnificent Seven",
    "original_language": "en",
    "title": "The Magnificent Seven",
    "backdrop_path": "\/g54J9MnNLe7WJYVIvdWTeTIygAH.jpg",
    "popularity": 32.363999,
    "vote_count": 386,
    "video": false,
    "vote_average": 4.63
}
 
  */


