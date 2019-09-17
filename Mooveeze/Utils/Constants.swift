//
//  Constants.swift
//  Mooveeze
//
//  Created by Bill on 10/6/16.
//  Copyright © 2016 Bill. All rights reserved.
//

import Foundation

//global functions
//MARK: dlog
public func dlog(_ message: String, _ filePath: String = #file, _ functionName: String = #function, _ lineNum: Int = #line)
{
    #if DEBUG
        
        let url  = URL(fileURLWithPath: filePath)
        let path = url.lastPathComponent
        var fileName = "Unknown"
        if let name = path.split(separator: ",").map(String.init).first {
            fileName = name
        }
        let logString = String(format: "%@.%@[%d]: %@", fileName, functionName, lineNum, message)
        NSLog(logString)
        
    #endif
    
}

public func loadSessionId() {
    if let val = UserDefaults.standard.string(forKey: "sessionId") {
        Constants.sessionId = val
    }
}

public func saveSessionId(_ seshId: String) {
    Constants.sessionId = seshId
    UserDefaults.standard.setValue(seshId, forKey: "sessionId")
}

public func deleteSessionId(_ seshId: String) {
    Constants.sessionId = nil
    UserDefaults.standard.setValue(nil, forKey: "sessionId")
}

public func userIsLoggedIn() -> Bool {
    
    guard let foundSessionId = Constants.sessionId, foundSessionId.count == 40 else {
        return false
    }
    return true
}

public struct Constants {
    
    public static let defaultAppearanceKey = "defaultAppearanceKey"
    public static let theMovieDbApiKeyName = "api_key"
    public static let theMovieDbSessionKeyName = "session_id"
    public static let theMovieDbApiKey = "d2f534caef1352faf672a1d1b1528999"
    public static let theMovieDbApiKeyParam = theMovieDbApiKeyName + "=" + theMovieDbApiKey
    public static let theMovieDbBaseImageUrl = "http://image.tmdb.org/t/p"
    public static let theMovieDbSecureBaseImageUrl = "https://image.tmdb.org/t/p"
    public static let theMovieDbBaseUrl = "https://api.themoviedb.org/3"
    public static let theMovieDbSecureBaseUrl = "https://api.themoviedb.org/3"

    public static let theMovieDbNowPlayingPath = "/movie/now_playing"
    public static let theMovieDbTopRatedPath = "/movie/top_rated"
    public static let theMovieDbSearchPath = "/search/movie"
    public static let theMovieDbMovieDetailPath = "/movie"
    public static let theMovieDbMovieVideoPath = "/videos"
    public static let theMovieDbProfilePath = "/account"
    public static let theMovieDbAuthTokenPath = "/authentication/token/new"
    public static let theMovieDbAuthTokenValidationPath = "/authentication/token/validate_with_login"
    public static let theMovieDbNewSessionPath = "/authentication/session/new"
    public static let theMovieDbDeleteSessionPath = "/authentication/session"

    public static let theMovieDbNowPlayingTitle = "Now Playing"
    public static let theMovieDbTopRatedTitle = "Top Rated"
    
    public static let gravatarBaseUrl = "https://secure.gravatar.com/avatar"

    public static var sessionId: String? = nil

    public static let backdropSizes = [
        "w300",
        "w780",
        "w1280",
        "original"
    ]

    public static let logo_sizes = [
        "w45",
        "w92",
        "w154",
        "w185",
        "w300",
        "w500",
        "original"
    ]

    public static let poster_sizes = [
        "w92",
        "w154",
        "w185",
        "w342",
        "w500",
        "w780",
        "original"
    ]

    public static let profile_sizes = [
        "w45",
        "w185",
        "h632",
        "original"
    ]

    public static let still_sizes = [
        "w92",
        "w185",
        "w300",
        "original"
    ]

    public static let genreMap: [Int: String] = [
        28: "Action",
        12: "Adventure",
        16: "Animation",
        35: "Comedy",
        80: "Crime",
        99: "Documentary",
        18: "Drama",
        10751: "Family",
        14: "Fantasy",
        36: "History",
        27: "Horror",
        10402: "Music",
        9648: "Mystery",
        10749: "Romance",
        878: "Science Fiction",
        10770: "TV Movie",
        53: "Thriller",
        10752: "War",
        37: "Western"
    ]
}
//junk

//MARK: MovieApi
/*
 You'll notice that movie, TV and person objects contain references to different file paths. In order to generate a fully working image URL, you'll need 3 pieces of data. Those pieces are a base_url, a file_size and a file_path.
 
 The first two pieces can be retrieved by calling the /configuration API and the third is the file path you're wishing to grab on a particular media object. Here's what a full image URL looks like if the poster_path of /kqjL17yufvn9OVLyXYpvtyrFfak.jpg was returned for a movie, and you were looking for the w500 size:
 
 https://image.tmdb.org/t/p/w500/kqjL17yufvn9OVLyXYpvtyrFfak.jpg
 
 https://image.tmdb.org/t/p/w500/8uO0gUM8aNqYLs1OsTBQiXu0fEv.jpg
 
 /* request token for auth: d33dd4e678031307f192237db532b15d8e0cb5ca */
 //https://api.themoviedb.org/3/search/movie?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed&language=en-US&query=seven
 //https://api.themoviedb.org/3/movie/now_playing?api_key=d2f534caef1352faf672a1d1b1528999&language=en-US
 */

/*
 
 https://api.themoviedb.org/3/configuration?api_key=d2f534caef1352faf672a1d1b1528999
 
 
 current config:
 {
 "images": {
 "base_url": "http://image.tmdb.org/t/p/",
 "secure_base_url": "https://image.tmdb.org/t/p/",
 "backdrop_sizes": [
 "w300",
 "w780",
 "w1280",
 "original"
 ],
 "logo_sizes": [
 "w45",
 "w92",
 "w154",
 "w185",
 "w300",
 "w500",
 "original"
 ],
 "poster_sizes": [
 "w92",
 "w154",
 "w185",
 "w342",
 "w500",
 "w780",
 "original"
 ],
 "profile_sizes": [
 "w45",
 "w185",
 "h632",
 "original"
 ],
 "still_sizes": [
 "w92",
 "w185",
 "w300",
 "original"
 ]
 },
 "change_keys": [
 "adult",
 "air_date",
 "also_known_as",
 "alternative_titles",
 "biography",
 "birthday",
 "budget",
 "cast",
 "certifications",
 "character_names",
 "created_by",
 "crew",
 "deathday",
 "episode",
 "episode_number",
 "episode_run_time",
 "freebase_id",
 "freebase_mid",
 "general",
 "genres",
 "guest_stars",
 "homepage",
 "images",
 "imdb_id",
 "languages",
 "name",
 "network",
 "origin_country",
 "original_name",
 "original_title",
 "overview",
 "parts",
 "place_of_birth",
 "plot_keywords",
 "production_code",
 "production_companies",
 "production_countries",
 "releases",
 "revenue",
 "runtime",
 "season",
 "season_number",
 "season_regular",
 "spoken_languages",
 "status",
 "tagline",
 "title",
 "translations",
 "tvdb_id",
 "tvrage_id",
 "type",
 "video",
 "videos"
 ]
 }
 
 */
