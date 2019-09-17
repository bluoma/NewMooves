//
//  MoviesCoordinator.swift
//  Mooveeze
//
//  Created by Bill on 9/5/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import UIKit

class MoviesCoordinator: BaseRootNavigationCoordinator {
    
    unowned var moviesViewController: MoviesViewController
    
    override init(withNavVc navVc: UINavigationController, config: CoordinatorConfig) {
        
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: MoviesViewController.self)) as? MoviesViewController else {
            fatalError()
        }
        
        moviesViewController = vc
        super.init(withNavVc: navVc, config: config)
        
        moviesViewController.title = config.vcTitle
        if let listType: MovieListType = MovieListType(rawValue: config.vcIndex) {
            moviesViewController.movieListType = listType
            let viewModel = MoviesViewModel(withType: listType)
            vc.moviesViewModel = viewModel
        }
        else {
            dlog("no listType specified in config")
            let viewModel = MoviesViewModel(withType: .nowPlaying)
            vc.moviesViewModel = viewModel
        }
        navVc.viewControllers.append(moviesViewController)
        moviesViewController.didSelectMovieDetail = moviesViewControllerDidSelectMovieDetail

    }
    
    
    func moviesViewControllerDidSelectMovieDetail(movie: Movie) {
        dlog("movie: \(movie)")
        
        guard let detailVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: MovieViewController.self)) as? MovieViewController else {
            fatalError()
        }
        detailVc.viewModel = MovieViewModel(movie: movie)
        detailVc.didSelectVideo = detailViewControllerDidSelectVideo
        navigationController.show(detailVc, sender: self)
    }
    
    func detailViewControllerDidSelectVideo(_ movieVideo: MovieVideo) {
        dlog("video: \(movieVideo)")
        
        guard let videoVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: MovieVideoWebViewController.self)) as? MovieVideoWebViewController else {
            fatalError()
        }
        
        videoVc.videoViewModel = MovieVideoViewModel(movieVideo: movieVideo)
        navigationController.show(videoVc, sender: self)
    }
}
