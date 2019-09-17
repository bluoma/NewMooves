//
//  MoviesViewModel.swift
//  Mooveeze
//
//  Created by Bill on 9/15/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import UIKit

class DynamicMoviesState {
    
    let searchBarState: Dynamic<Bool>
    let movieListPageLoadState: Dynamic<Int>
    let downloadDidBegin: Dynamic<Bool>
    let downloadDidEnd: Dynamic<Bool>
    let downloadDidError: Dynamic<Error?>
    
    
    init() {
        searchBarState = Dynamic(false)
        movieListPageLoadState = Dynamic(1)
        downloadDidBegin = Dynamic(false)
        downloadDidEnd = Dynamic(false)
        downloadDidError = Dynamic(nil)
    }
    
}


class MoviesViewModel {
    
    fileprivate var movieModels: [MovieViewModel] = []
    fileprivate var filteredMovieModels: [MovieViewModel] = [] {
        didSet {
            dlog("filteredCount: \(filteredMovieModels.count)")
            dynamicMoviesState.searchBarState.value = self.searchIsActive
        }
    }
    
    fileprivate var searchIsActive: Bool = false
    fileprivate let moviesService = MoviesService()
    let dynamicMoviesState = DynamicMoviesState()
    var movieListType: MovieListType = .nowPlaying
    fileprivate var downloadIsInProgress: Bool = false
    fileprivate var totalPages: Int = 0
    fileprivate var currentPage: Int = 1
    fileprivate var totalCount: Int = 0
    
    init(withType movieListType: MovieListType) {
        self.movieListType = movieListType
    }
    
    func selectedMovie(at indexPath: IndexPath) -> Movie? {
     
        var movie: Movie?
        if searchIsActive {
            if indexPath.row < filteredMovieModels.count {
                movie = filteredMovieModels[indexPath.row].selectedMovie
            }
            else {
                assert(false, "filtered movies array oob: \(indexPath)")
            }
        }
        else {
            if indexPath.row < movieModels.count {
                movie = movieModels[indexPath.row].selectedMovie
            }
            else {
                assert(false, "movies array oob: \(indexPath)")
            }
        }
        return movie
    }
    
    func selectedMovieViewModel(at indexPath: IndexPath) -> MovieViewModel? {
        
        var movieViewModel: MovieViewModel?
        if searchIsActive {
            if indexPath.row < filteredMovieModels.count {
                movieViewModel = filteredMovieModels[indexPath.row]
            }
            else {
                assert(false, "filtered movies array oob: \(indexPath)")
            }
        }
        else {
            if indexPath.row < movieModels.count {
                movieViewModel = movieModels[indexPath.row]
            }
            else {
                assert(false, "movies array oob: \(indexPath)")
            }
        }
        return movieViewModel
    }
    
    func moviesCount() -> Int {
        if searchIsActive {
            return filteredMovieModels.count
        }
        return movieModels.count
    }
    
}

//MARK: - Search
extension MoviesViewModel {
    
    func searchIsActive(_ searching: Bool, forText searchText: String = "") {
        self.searchIsActive = searching
        if searching {
            filteredMovieModels = movieModels.filter({ (movieModel) -> Bool in
                let pattern = "\\b" + searchText + "\\b"
                let searchTarget = movieModel.dynamicMovie.title.value + " " + movieModel.dynamicMovie.overview.value
                let range = searchTarget.range(of: pattern, options: [.caseInsensitive, .regularExpression])
                return range != nil
            })
        }
        else {
            filteredMovieModels = []
        }
    }
}

//MARK: - Network
extension MoviesViewModel {
    
    fileprivate func beginDownload() {
        dynamicMoviesState.downloadDidBegin.value = true
        dynamicMoviesState.downloadDidError.value = nil
    }
    
    fileprivate func endDownload() {
        dynamicMoviesState.downloadDidEnd.value = true
    }
    
    func fetchMovies(page: Int = 1) {
        
        if downloadIsInProgress || searchIsActive { return }
        if page > 1 && page >= totalPages { return }
        
        downloadIsInProgress = true
        beginDownload()
        
        moviesService.fetchMovieList(withType: movieListType, page: page, completion:
        { [weak self] (movieResults: MovieResults?, error: Error?) in
            guard let myself = self else { return }
            
            myself.endDownload()
            myself.downloadIsInProgress = false
            
            if error != nil {
                dlog("err: \(String(describing: error))")
                myself.dynamicMoviesState.downloadDidError.value = error
            }
            else if let results = movieResults {
                myself.currentPage = page
                myself.totalCount = results.totalResults
                myself.totalPages = results.totalPages
                
                var viewModels: [MovieViewModel] = []
                
                for movie in results.movies {
                    viewModels.append(MovieViewModel(movie: movie))
                }
                
                if myself.currentPage > 1 {
                    myself.movieModels += viewModels
                }
                else {
                    myself.movieModels = viewModels
                }
                myself.dynamicMoviesState.movieListPageLoadState.value = myself.currentPage
                
            }
            else {
                assert(false, "no error, no results")
            }
        })
    }
}
    

