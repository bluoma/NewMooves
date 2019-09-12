//
//  MovieDetailViewModel.swift
//  Mooveeze
//
//  Created by Bill on 9/11/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

protocol DynamicMovieDetail {
    //movie model properties
    var movieId: Dynamic<Int> { get }
    var title: Dynamic<String> { get }
    var adult: Dynamic<Bool> { get }
    var overview:  Dynamic<String> { get }
    var releaseDate: Dynamic<Date> { get }
    var originalTitle:  Dynamic<String> { get }
    var originalLanguage: Dynamic<String> { get }
    var posterPath: Dynamic<String?> { get }
    var backdropPath: Dynamic<String?> { get }
    var popularity: Dynamic<Double> { get }
    var voteCount: Dynamic<Int> { get }
    var video: Dynamic<Bool> { get }
    var voteAverage: Dynamic<Double> { get }
    var genreIds: Dynamic<[Int]> { get }
    
    //movie model properties set manually
    var movieDetail: Dynamic<MovieDetail?> { get }
    //var movieVideos: [MovieVideo] { get }
    
    //movie model properties calculated
    var genreNames: Dynamic<[String]> { get }
}

fileprivate class MovieDetailViewModelWrapper: DynamicMovieDetail {
    //movie model properties
    let movieId: Dynamic<Int>
    let title: Dynamic<String>
    let adult: Dynamic<Bool>
    let overview: Dynamic<String>
    let releaseDate: Dynamic<Date>
    let originalTitle: Dynamic<String>
    let originalLanguage: Dynamic<String>
    let posterPath: Dynamic<String?>
    let backdropPath: Dynamic<String?>
    let popularity: Dynamic<Double>
    let voteCount: Dynamic<Int>
    let video: Dynamic<Bool>
    let voteAverage: Dynamic<Double>
    let genreIds: Dynamic<[Int]>
    
    //movie model properties set manually
    let movieDetail: Dynamic<MovieDetail?>
    //let movieVideos: [MovieVideo]
    
    //movie model properties calculated
    let genreNames: Dynamic<[String]>
    
    init(movie: Movie?) {
        if let movie = movie {
            movieId = Dynamic(movie.movieId)
            title = Dynamic(movie.title)
            adult = Dynamic(movie.adult)
            overview = Dynamic(movie.overview)
            releaseDate = Dynamic(movie.releaseDate)
            originalTitle = Dynamic(movie.originalTitle)
            originalLanguage = Dynamic(movie.originalLanguage)
            posterPath = Dynamic(movie.posterPath)
            backdropPath = Dynamic(movie.backdropPath)
            popularity = Dynamic(movie.popularity)
            voteCount = Dynamic(movie.voteCount)
            video = Dynamic(movie.video)
            voteAverage = Dynamic(movie.voteAverage)
            genreIds = Dynamic(movie.genreIds)
            movieDetail = Dynamic(movie.movieDetail)
            genreNames = Dynamic(movie.genreNames)
        }
        else {
            movieId = Dynamic(-1)
            title = Dynamic("")
            adult = Dynamic(false)
            overview = Dynamic("")
            releaseDate = Dynamic(Date())
            originalTitle = Dynamic("")
            originalLanguage = Dynamic("")
            posterPath = Dynamic(nil)
            backdropPath = Dynamic(nil)
            popularity = Dynamic(0.0)
            voteCount = Dynamic(0)
            video = Dynamic(false)
            voteAverage = Dynamic(0.0)
            genreIds = Dynamic([])
            movieDetail = Dynamic(nil)
            genreNames = Dynamic([])
        }
        
    }
}

class MovieDetailViewModel {
    
    fileprivate var movieDetailWrapper: MovieDetailViewModelWrapper
    
    var dynamicMovieDetail: DynamicMovieDetail {
        get {
            return movieDetailWrapper
        }
    }
    
    init(movie: Movie) {
        
        movieDetailWrapper = MovieDetailViewModelWrapper(movie: movie)
    }
    
}
