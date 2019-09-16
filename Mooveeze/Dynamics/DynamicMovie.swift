//
//  DynamicMovie.swift
//  Mooveeze
//
//  Created by Bill on 9/15/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import UIKit


protocol DynamicMovie: class {
    //movie model properties
    var movieId: Dynamic<Int> { get }
    var title: Dynamic<String> { get }
    var adult: Dynamic<Bool> { get }
    var overview:  Dynamic<String> { get }
    var releaseDate: Dynamic<String> { get }
    var originalTitle:  Dynamic<String> { get }
    var originalLanguage: Dynamic<String> { get }
    var posterPath: Dynamic<String?> { get }
    var backdropImage: Dynamic<UIImage?> { get }
    var popularity: Dynamic<Double> { get }
    var voteCount: Dynamic<Int> { get }
    var video: Dynamic<Bool> { get }
    var voteAverage: Dynamic<Double> { get }
    //movie model properties calculated
    var selectedGenre: Dynamic<String> { get }
    //movie model detail properties set manually if detail nil
    var tagline: Dynamic<String> { get }
    var runtimeString: Dynamic<String> { get }
    var homepage: Dynamic<String> { get }
    var videosLoaded: Dynamic<Bool> { get }
    
}


class MovieViewModelWrapper: DynamicMovie {
    //movie model properties
    let movieId: Dynamic<Int>
    let title: Dynamic<String>
    let adult: Dynamic<Bool>
    let overview: Dynamic<String>
    let releaseDate: Dynamic<String>
    let originalTitle: Dynamic<String>
    let originalLanguage: Dynamic<String>
    let posterPath: Dynamic<String?>
    var backdropImage: Dynamic<UIImage?>
    let popularity: Dynamic<Double>
    let voteCount: Dynamic<Int>
    let video: Dynamic<Bool>
    let voteAverage: Dynamic<Double>
    //movie model properties calculated
    let selectedGenre: Dynamic<String>
    
    //movie model detail properties set manually if detail nil
    let tagline: Dynamic<String>
    let runtimeString: Dynamic<String>
    let homepage: Dynamic<String>
    let videosLoaded: Dynamic<Bool>
    
    init(movie: Movie?) {
        let defaultImage = UIImage(named: "default_poster_image.png")
        
        if let movie = movie {
            
            movieId = Dynamic(movie.movieId)
            title = Dynamic(movie.title)
            adult = Dynamic(movie.adult)
            overview = Dynamic(movie.overview)
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            let releaseDateString = dateFormatter.string(from: movie.releaseDate)
            releaseDate = Dynamic(releaseDateString)
            originalTitle = Dynamic(movie.originalTitle)
            originalLanguage = Dynamic(movie.originalLanguage)
            posterPath = Dynamic(movie.posterPath)
            backdropImage = Dynamic(defaultImage)
            popularity = Dynamic(movie.popularity)
            voteCount = Dynamic(movie.voteCount)
            video = Dynamic(movie.video)
            voteAverage = Dynamic(movie.voteAverage)
            if (movie.genreNames.count > 0) {
                selectedGenre = Dynamic(movie.genreNames[0])
            }
            else {
                selectedGenre = Dynamic("")
            }
            //flatten the detail if present
            if let detail = movie.movieDetail {
                tagline = Dynamic(detail.tagline)
                runtimeString = Dynamic(MovieViewModelWrapper.runtimeToString(detail.runtime))
                if let home = detail.homepage {
                    homepage = Dynamic(home)
                }
                else {
                    homepage = Dynamic("")
                }
            }
            else {
                tagline = Dynamic("")
                runtimeString = Dynamic("")
                homepage = Dynamic("")
            }
            videosLoaded = Dynamic(false)
        }
        else {
            movieId = Dynamic(-1)
            title = Dynamic("")
            adult = Dynamic(false)
            overview = Dynamic("")
            releaseDate = Dynamic("")
            originalTitle = Dynamic("")
            originalLanguage = Dynamic("")
            posterPath = Dynamic(nil)
            backdropImage = Dynamic(defaultImage)
            popularity = Dynamic(0.0)
            voteCount = Dynamic(0)
            video = Dynamic(false)
            voteAverage = Dynamic(0.0)
            selectedGenre = Dynamic("")
            tagline = Dynamic("")
            runtimeString = Dynamic("")
            homepage = Dynamic("")
            videosLoaded = Dynamic(false)
        }
        
    }
    
    func update(withDetail detail: MovieDetail) {
        tagline.value = detail.tagline
        runtimeString.value = MovieViewModelWrapper.runtimeToString(detail.runtime)
        if let home = detail.homepage {
            homepage.value = home
        }
        else {
            homepage.value = ""
        }
    }
    
    static func runtimeToString(_ runningTime: Int) -> String {
        
        guard runningTime > 0  else { return "" }
        let hours =  runningTime / 60
        let minutes =  runningTime % 60
        let runtimeString = "\(hours) hr \(minutes) min"
        
        return runtimeString
    }
    
    deinit {
        dlog(String(describing: self))
    }
}
