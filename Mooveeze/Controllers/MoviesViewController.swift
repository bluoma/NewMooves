//
//  MoviesViewController.swift
//  Mooveeze
//
//  Created by Bill on 10/6/16.
//  Copyright © 2016 Bill. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class MoviesViewController: UIViewController {

    @IBOutlet weak var moviesTableView: UITableView!
    @IBOutlet weak var moviesSearchBar: UISearchBar!
    
    var movieListType: MovieListType = .nowPlaying
    var isNetworkErrorShowing: Bool = false
    var header = UITableViewHeaderFooterView()
    var moviesRefreshControl: UIRefreshControl!
    var currentPage: Int = 1
    //injected by coordinator
    var moviesViewModel: MoviesViewModel!
    var dynamicMoviesState: DynamicMoviesState! {
        didSet {
            dynamicMoviesState.searchBarState.bind {
                [unowned self] (searchBarState: Bool) in
                dlog("searchState: \(searchBarState)")
                self.moviesTableView.reloadData()
            }
            dynamicMoviesState.movieListPageLoadState.bind {
                [unowned self] (page: Int) in
                dlog("pageLoadState: \(page)")
                self.currentPage = page
                self.moviesTableView.reloadData()
            }
            dynamicMoviesState.downloadDidBegin.bind {
                [unowned self] (didBegin: Bool) in
                //dlog("didBegin: \(didBegin)")
                if (didBegin) {
                    self.beginDownload()
                }
            }
            dynamicMoviesState.downloadDidEnd.bind {
                [unowned self] (didEnd: Bool) in
                //dlog("didEnd: \(didEnd)")
                if (didEnd) {
                    self.endDownload()
                }
            }
            dynamicMoviesState.downloadDidError.bind {
                [unowned self] (error: Error?) in
                if error != nil {
                    self.isNetworkErrorShowing = true
                    self.moviesTableView.reloadData()
                }
                else {
                    self.isNetworkErrorShowing = false
                }
            }
        }
    }
    
    var didSelectMovieDetail: ((Movie) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dynamicMoviesState = moviesViewModel.dynamicMoviesState
        moviesRefreshControl = UIRefreshControl()
        moviesRefreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControl.Event.valueChanged)
    
        self.moviesTableView.refreshControl = moviesRefreshControl
        self.moviesTableView.estimatedRowHeight = 96
        self.moviesTableView.rowHeight = UITableView.automaticDimension
        self.moviesTableView.tableFooterView = UIView()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        header.addGestureRecognizer(tapRecognizer)
        
        moviesViewModel.fetchMovies(page: 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @objc func handleTap(gestureRecognizer: UIGestureRecognizer)
    {
        dlog("Header Tapped")
        isNetworkErrorShowing = !isNetworkErrorShowing
        moviesTableView.reloadData()
    }
    
    //MARK: - Network
    @objc func refreshControlAction(refreshControl: UIRefreshControl) {
        dlog("");
        if dynamicMoviesState.searchBarState.value {
            moviesSearchBar.endEditing(true)
            moviesViewModel.searchIsActive(false)
            
        }
        currentPage = 1
        moviesViewModel.fetchMovies(page: currentPage)
    }

    fileprivate func beginDownload() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        if !moviesRefreshControl.isRefreshing && currentPage == 1 {
            moviesTableView.setContentOffset(CGPoint(x: 0, y: -moviesRefreshControl.bounds.height), animated: false)
            moviesRefreshControl.beginRefreshing()
        }
        self.isNetworkErrorShowing = false
    }
    
    fileprivate func endDownload() {
        moviesRefreshControl.endRefreshing()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        if currentPage > 1 {
            self.moviesTableView.tableFooterView = UIView()
        }
    }
}

//MARK: - UITableViewDelegate
extension MoviesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dlog("row: \(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let movie: Movie = moviesViewModel.selectedMovie(at: indexPath) else {
            dlog("no movie at indexPath: \(indexPath)")
            return
        }
        
        self.didSelectMovieDetail?(movie)
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if dynamicMoviesState.searchBarState.value { return }
        let count = moviesViewModel.moviesCount()
     
        if count > 0 && indexPath.row >= count - 1 {
            dlog("indexPath: \(indexPath) at end")
            var footerFrame = cell.bounds
            footerFrame.size.height = 44
            let footer = UIView(frame: footerFrame)
            let spinner = UIActivityIndicatorView()
            spinner.style = .whiteLarge
            spinner.color = .darkGray
            spinner.tintColor = .darkGray
            spinner.center = footer.center
            spinner.startAnimating()
            footer.addSubview(spinner)
            tableView.tableFooterView = footer
            
            moviesViewModel.fetchMovies(page: currentPage + 1)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isNetworkErrorShowing {
            return 44.0;
        }
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        dlog("")
        header.textLabel?.text = dynamicMoviesState.downloadDidError.value?.localizedDescription
        header.textLabel?.textColor = UIColor.red
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        header.textLabel?.textAlignment = NSTextAlignment.center
    }
    
    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        dlog("")
    }
}

//MARK: - UITableViewDataSource
extension MoviesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return moviesViewModel.moviesCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieSummaryCell") as? MovieSummaryTableViewCell,
            let movieModel = moviesViewModel.selectedMovieViewModel(at: indexPath) else {
            return UITableViewCell()
        }
        
        cell.dynamicMovie = movieModel.dynamicMovie
        movieModel.fetchThumbnailImage()
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        dlog("isNetworkErrorShowing: \(isNetworkErrorShowing)")
        if isNetworkErrorShowing {
            return header
        }
        return nil
    }
}

//MARK: - UIScrollViewDelegate
extension MoviesViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //dlog("contentSize: \(scrollView.contentSize), contentOffset: \(scrollView.contentOffset)")
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        //dlog("contentSize: \(scrollView.contentSize), contentOffset: \(scrollView.contentOffset)")
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //dlog("contentSize: \(scrollView.contentSize), contentOffset: \(scrollView.contentOffset)")
    }

}

//MARK: - UISearchBarDelegate
extension MoviesViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        dlog("searchText: \(searchText)")
        
        if searchText.count == 0 {
            moviesViewModel.searchIsActive(false)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dlog("searchBarText: \(String(describing: searchBar.text))")
        searchBar.endEditing(true)
        if let searchBarText = searchBar.text {
            moviesViewModel.searchIsActive(true, forText: searchBarText)
        }
        else {
            dlog("no search text")
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dlog("")
        searchBar.endEditing(true)
        moviesViewModel.searchIsActive(false)
    }
}
