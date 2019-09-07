//
//  ApplicationCoordinator.swift
//  Mooveeze
//
//  Created by Bill on 8/8/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import UIKit

class ApplicationCoordinator {

    var rootViewController: UITabBarController
    var navigationCoordinators: [BaseCoordinator] = []
    
    
    init() {
        let tabBarController = UITabBarController()
        
        let index0 = 0
        let index1 = 1
        let index2 = 2
        
        let title0 = "Now Playing"
        let title1 = "Top Rated"
        let title2 = "Profile"
        
        let icon0 = UIImage(named: "now_playing_icon")
        let icon1 = UIImage(named: "top_rated_icon")
        let icon2 = UIImage(named: "profile_icon")
        
        let navController0: UINavigationController = UINavigationController()
        let navController1: UINavigationController = UINavigationController()
        let navController2: UINavigationController = UINavigationController()
        
     
        let config0 = CoordinatorConfig(vcIndex: index0, vcTitle: title0, vcUrlPath: Constants.theMovieDbNowPlayingPath)
        let config1 = CoordinatorConfig(vcIndex: index1, vcTitle: title1, vcUrlPath: Constants.theMovieDbTopRatedPath)
        let config2 = CoordinatorConfig(vcIndex: index2, vcTitle: title2, vcUrlPath: Constants.theMovieDbProfilePath)

        let nowPlayingMoviesCoordinator = MoviesCoordinator(withNavVc: navController0, config: config0)
        navigationCoordinators.append(nowPlayingMoviesCoordinator)
        
        let topRatedMoviesCoordinator = MoviesCoordinator(withNavVc: navController1, config: config1)
        navigationCoordinators.append(topRatedMoviesCoordinator)
        
        let profileCoordinator = ProfileCoordinator(withNavVc: navController2, config: config2)
        navigationCoordinators.append(profileCoordinator)
        
        let item0 = UITabBarItem(title: title0, image: icon0, tag: index0)
        let item1 = UITabBarItem(title: title1, image: icon1, tag: index1)
        let item2 = UITabBarItem(title: title2, image: icon2, tag: index2)
        
        navController0.tabBarItem = item0
        navController1.tabBarItem = item1
        navController2.tabBarItem = item2
        tabBarController.viewControllers = [navController0, navController1, navController2]
        
        rootViewController = tabBarController
    }

}

