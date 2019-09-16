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

class MovieViewModel {
    
    fileprivate let moviesService = MoviesService()
    fileprivate var movieDetailWrapper: MovieViewModelWrapper
    fileprivate let movie: Movie
    fileprivate var movieVideoViewModels: [MovieVideoViewModel] = []
    
    init(movie: Movie) {
        self.movie = movie
        movieDetailWrapper = MovieViewModelWrapper(movie: movie)
    }
    
    var dynamicMovie: DynamicMovie {
        get {
            return movieDetailWrapper
        }
    }
    
    var selectedMovie: Movie {
        return movie
    }
    
    var videoCellCount: Int {
        return movieVideoViewModels.count
    }
    
    func videoCellViewModel(at indexPath: IndexPath ) -> MovieVideoViewModel {
        if indexPath.row >= movieVideoViewModels.count {
            assert(false, "mvvm array oob: \(indexPath)")
        }
        return movieVideoViewModels[indexPath.row]
    }
    
    func selectedMovieVideo(at indexPath: IndexPath) -> MovieVideo? {
        var movieVideo: MovieVideo?
        
        if indexPath.row < movie.movieVideos.count {
            movieVideo = movie.movieVideos[indexPath.row]
        }
        else {
            assert(false, "mvv array oob: \(indexPath)")
        }
        
        return movieVideo
    }
    
    
    //MARK: - Network
    func fetchMovieDetail() {
        
        if movie.movieDetail != nil { return }
        
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
    
    func fetchMovieVideos() {
        
        if !movie.movieVideos.isEmpty {
            self.movieVideoViewModels = []
            for video in movie.movieVideos {
                let vm = MovieVideoViewModel(movieVideo: video)
                self.movieVideoViewModels.append(vm)
            }
            DispatchQueue.main.async {
                self.movieDetailWrapper.videosLoaded.value = true
            }
            return
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let movieId = movie.movieId
        
        moviesService.fetchMovieVideos(byId: movieId, completion:
        { [weak self] (videos: [MovieVideo], error: Error?) -> Void in
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            guard let myself = self else { return }
            
            if error != nil {
                dlog("err: \(String(describing: error))")
                myself.movieDetailWrapper.videosLoaded.value = false
            }
            else {
                myself.movie.movieVideos = videos
                myself.movieVideoViewModels = []
                for video in videos {
                    let vm = MovieVideoViewModel(movieVideo: video)
                    myself.movieVideoViewModels.append(vm)
                }
                myself.movieDetailWrapper.videosLoaded.value = true
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
    
    func fetchThumbnailImage() {
        guard let posterPath = movie.posterPath, posterPath.count > 0 else { return }
        
        let imageUrlString = Constants.theMovieDbSecureBaseImageUrl + "/" + Constants.poster_sizes[0] + posterPath
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
