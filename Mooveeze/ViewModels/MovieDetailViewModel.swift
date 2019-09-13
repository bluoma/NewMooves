//
//  MovieDetailViewModel.swift
//  Mooveeze
//
//  Created by Bill on 9/11/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

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
    var backdropImage: Dynamic<UIImage?> { get }
    var popularity: Dynamic<Double> { get }
    var voteCount: Dynamic<Int> { get }
    var video: Dynamic<Bool> { get }
    var voteAverage: Dynamic<Double> { get }
    //movie model properties calculated
    var selectedGenre: Dynamic<String> { get }
    //movie model detail properties set manually if detail nil
    var tagline: Dynamic<String> { get }
    var runtime: Dynamic<Int> { get }
    var homepage: Dynamic<String> { get }
    //var movieVideos: [MovieVideo] { get }
    
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
    var backdropImage: Dynamic<UIImage?>
    let popularity: Dynamic<Double>
    let voteCount: Dynamic<Int>
    let video: Dynamic<Bool>
    let voteAverage: Dynamic<Double>
    //movie model properties calculated
    let selectedGenre: Dynamic<String>
    
    //movie model detail properties set manually if detail nil
    let tagline: Dynamic<String>
    let runtime: Dynamic<Int>
    let homepage: Dynamic<String>
    //let movieVideos: [MovieVideo]
    
    init(movie: Movie?) {
        let defaultImage = UIImage(named: "default_poster_image.png")

        if let movie = movie {
            movieId = Dynamic(movie.movieId)
            title = Dynamic(movie.title)
            adult = Dynamic(movie.adult)
            overview = Dynamic(movie.overview)
            releaseDate = Dynamic(movie.releaseDate)
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
                runtime = Dynamic(detail.runtime)
                homepage = Dynamic(detail.homepage)
            }
            else {
                tagline = Dynamic("")
                runtime = Dynamic(0)
                homepage = Dynamic("")
            }
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
            backdropImage = Dynamic(defaultImage)
            popularity = Dynamic(0.0)
            voteCount = Dynamic(0)
            video = Dynamic(false)
            voteAverage = Dynamic(0.0)
            selectedGenre = Dynamic("")
            tagline = Dynamic("")
            runtime = Dynamic(0)
            homepage = Dynamic("")
        }
        
    }
    
    func update(withDetail detail: MovieDetail) {
        tagline.value = detail.tagline
        runtime.value = detail.runtime
        homepage.value = detail.homepage
    }
}

class MovieDetailViewModel {
    
    fileprivate let moviesService = MoviesService()
    fileprivate var movieDetailWrapper: MovieDetailViewModelWrapper
    fileprivate let movie: Movie
    var dynamicMovieDetail: DynamicMovieDetail {
        get {
            return movieDetailWrapper
        }
    }
    
    init(movie: Movie) {
        
        movieDetailWrapper = MovieDetailViewModelWrapper(movie: movie)
        self.movie = movie
    }
    
    //MARK: - Network
    func fetchMovieDetail() {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        moviesService.fetchMovieDetail(byId: movieDetailWrapper.movieId.value, completion:
        { [weak self] (detail: MovieDetail?, error: Error?) -> Void in
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            guard let myself = self else { return }
            
            if let detail = detail {
                myself.movieDetailWrapper.update(withDetail: detail)
                myself.movie.movieDetail = detail
            }
            else if let error = error {
                dlog("err: \(String(describing: error))")
            }
            else {
                assert(false, "error and detail are nil")
            }
        })
    }
    
    func fetchBackdropImage() {
        guard let posterPath = movie.posterPath, posterPath.count > 0 else { return }
        
        let imageUrlString = Constants.theMovieDbSecureBaseImageUrl + "/" + Constants.poster_sizes[4] + posterPath
        
        guard let imageUrl = URL(string: imageUrlString) else {
            dlog("no url for posterPath: \(imageUrlString))")
            return
        }
        let urlRequest: URLRequest = URLRequest(url: imageUrl)
    
        ImageDownloader.default.download(urlRequest)
        { [weak self] (response: DataResponse<UIImage>) in
            guard let myself = self else { return }
            
            if let image: UIImage = response.value {
                myself.movieDetailWrapper.backdropImage.value = image
            }
            else {
                dlog("response is not a uiimage: \(String(describing: response.value))")
            }
        }
    }
    
    deinit {
        dlog("deinit")
    }
    
}
