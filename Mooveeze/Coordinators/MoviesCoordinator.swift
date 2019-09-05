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
        moviesViewController.endpointPath = config.vcUrlPath
        navVc.viewControllers.append(moviesViewController)
        moviesViewController.didSelectDetail = moviesViewControllerDidSelectDetail

    }
    
    
    func moviesViewControllerDidSelectDetail(summary: MovieSummary) {
        dlog("summary: \(summary)")
        
        guard let detailVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: MovieDetailViewController.self)) as? MovieDetailViewController else {
            fatalError()
        }
        
        detailVc.movieSummary = summary
        detailVc.didSelectVideo = detailViewControllerDidSelectVideo
        navigationController.show(detailVc, sender: self)
    }
    
    func detailViewControllerDidSelectVideo(index: Int, summary: MovieSummary) {
        dlog("summary: \(summary)")
        
        guard let videoVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: MovieVideoWebViewController.self)) as? MovieVideoWebViewController else {
            fatalError()
        }
        
        videoVc.movieSummary = summary
        videoVc.videoIndex = index
        navigationController.show(videoVc, sender: self)
    }
}
