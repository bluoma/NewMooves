//
//  MovieSummaryDTO.swift
//  Mooveeze
//
//  Created by Bill on 10/7/16.
//  Copyright © 2016 Bill. All rights reserved.
//

//2080651782

import UIKit

struct MovieDetail: Codable, CustomStringConvertible, CustomDebugStringConvertible {
    
    let tagline: String
    let runtime: Int
    let homepage: String
    
    enum CodingKeys: String, CodingKey {
        case tagline
        case runtime
        case homepage
    }
    
    var description: String {
        return "tagline: \(tagline), runningTime: \(runtime), homepage: \(homepage)"
    }
    
    var debugDescription: String {
        return "tagline: \(tagline), runningTime: \(runtime), homepage: \(homepage)"
    }

}

struct MovieVideoResults: Codable {
    let videos: [MovieVideo]
    
     enum CodingKeys: String, CodingKey {
        case videos = "results"
    }
}

struct MovieVideo: Codable, CustomStringConvertible, CustomDebugStringConvertible {
    
    let videoId: String
    let language: String //"iso_639_1"
    let region: String   //"iso_3166_1"
    let key: String
    let name: String
    let site: String
    let size: Int
    let type: String
    
   
    enum CodingKeys: String, CodingKey {
        case videoId = "id"
        case language = "iso_639_1"
        case region = "iso_3166_1"
        case key
        case name
        case site
        case size
        case type
    }
    var description: String {
        return "site: \(site), key: \(key), name: \(name)"
    }
    
    var debugDescription: String {
        return "site: \(site), key: \(key), name: \(name)"
    }
    
}

//we want this by reference
class Movie: Codable, CustomStringConvertible, CustomDebugStringConvertible {
    
    let movieId: Int
    let title: String
    let adult: Bool
    let overview: String
    let releaseDate: Date
    let originalTitle: String
    let originalLanguage: String
    let posterPath: String?
    let backdropPath: String?
    let popularity: Double
    let voteCount: Int
    let video: Bool
    let voteAverage: Double
    let genreIds: [Int]
    
    //set manually
    var movieDetail: MovieDetail?
    var movieVideos: [MovieVideo] = []
    
    //calculated
    var genreNames: [String] = []
    
    func populateGenres() {
        var genreNames: [String] = []
        for genreId in self.genreIds {
            if let genreName = Constants.genreMap[genreId] {
                genreNames.append(genreName)
            }
        }
        self.genreNames = genreNames
    }
    
    enum CodingKeys: String, CodingKey {
        
        case movieId = "id"
        case title
        case adult
        case overview
        case releaseDate = "release_date"
        case originalTitle = "original_title"
        case originalLanguage = "original_language"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case popularity
        case voteCount = "vote_count"
        case video
        case voteAverage = "vote_average"
        case genreIds = "genre_ids"
    }
    
    var description: String {
        return "title: \(title), genreIds: \(genreIds), genreNames: \(genreNames), releaseDate: \(String(describing: releaseDate))"
    }
    
    var debugDescription: String {
        
        return "title: \(title), genreIds: \(genreIds), genreNames: \(genreNames), releaseDate: \(String(describing: releaseDate))"
    }
}

struct MovieResults: Codable, CustomStringConvertible, CustomDebugStringConvertible {
    
    let totalResults: Int
    let totalPages: Int
    let page: Int
    let movies: [Movie]
    
    enum CodingKeys: String, CodingKey {
        
        case totalResults = "total_results"
        case totalPages = "total_pages"
        case page
        case movies = "results"
    }
    
    var description: String {
        return "totalResults: \(totalResults), totalPages: \(totalPages), page: \(page), count: \(movies.count)"
    }
    
    var debugDescription: String {
        return "totalResults: \(totalResults), totalPages: \(totalPages), page: \(page), count: \(movies.count)"
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
 
 {
 "results": [
 {
 "popularity": 287.8,
 "vote_count": 72,
 "video": false,
 "poster_path": "/wF6SNPcUrTKFA4fOFfukm7zQ3ob.jpg",
 "id": 474350,
 "adult": false,
 "backdrop_path": "/2V5RR4Ps1i4x7ifjjDvlmrSYzvL.jpg",
 "original_language": "en",
 "original_title": "It: Chapter Two",
 "genre_ids": [
 27
 ],
 "title": "It: Chapter Two",
 "vote_average": 7.3,
 "overview": "27 years after overcoming the malevolent supernatural entity Pennywise, the former members of the Losers' Club, who have grown up and moved away from Derry, are brought back together by a devastating phone call.",
 "release_date": "2019-09-06"
 }
 ],
 "page": 1,
 "total_results": 1132,
 "dates": {
 "maximum": "2019-09-11",
 "minimum": "2019-07-25"
 },
 "total_pages": 57
 }
 
 
  */


