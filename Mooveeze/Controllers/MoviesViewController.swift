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
    
    let httpClient = MoviesHttpClient()
    var moviesArray: [Movie] = []
    var filteredMoviesArray: [Movie] = []
    var endpointPath: String = ""
    var isNetworkErrorShowing: Bool = false
    var header = UITableViewHeaderFooterView()
    var searchActive = false
    var moviesRefreshControl: UIRefreshControl!
    var downloadIsInProgress: Bool = false
    var totalPages: Int = 0
    var currentPage: Int = 1
    var totalCount: Int = 0
    
    var didSelectMovieDetail: ((Movie) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        fetchMovies(page: 1)
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
        if searchActive {
            searchActive = false
            moviesSearchBar.endEditing(true)
            moviesTableView.reloadData()
        }
        if downloadIsInProgress { return }
        currentPage = 1
        fetchMovies(page: 1)
    }

    fileprivate func beginDownload() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        if !moviesRefreshControl.isRefreshing && currentPage == 1 {
            moviesTableView.setContentOffset(CGPoint(x: 0, y: -moviesRefreshControl.bounds.height), animated: false)
            moviesRefreshControl.beginRefreshing()
        }
    }
    
    fileprivate func endDownload() {
        moviesRefreshControl.endRefreshing()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.isNetworkErrorShowing = false
        if currentPage > 1 {
            self.moviesTableView.tableFooterView = UIView()
        }
        
    }
    
    fileprivate func fetchMovies(page: Int = 1) {
        
        if downloadIsInProgress || searchActive { return }
        //if page > 1 && page >= totalPages { return }
        
        isNetworkErrorShowing = false
        header.textLabel?.text = ""
        downloadIsInProgress = true
        beginDownload()
        
        let params = ["page" : page as AnyObject]
        
        httpClient.fetchNowPlayingMovieList(params: params, completion:
        { [weak self] (movieResults: MovieResults?, error: NSError?) in
            guard let strongself = self else { return }
            
            strongself.endDownload()
            strongself.downloadIsInProgress = false
            
            if error != nil {
                dlog("err: \(String(describing: error))")
                strongself.isNetworkErrorShowing = true
                strongself.moviesTableView.reloadData()
            }
            else if let results = movieResults {
                strongself.currentPage = page
            
                if strongself.currentPage > 1 {
                    strongself.moviesArray += results.movies
                }
                else {
                    strongself.moviesArray = results.movies
                }
                strongself.moviesTableView.reloadData()
            }
        })
    }
}

//MARK: - UITableViewDelegate
extension MoviesViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dlog("row: \(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: true)
        
        var movie: Movie!
        if searchActive {
            movie = filteredMoviesArray[indexPath.row]
        }
        else {
            movie = moviesArray[indexPath.row]
        }
        self.didSelectMovieDetail?(movie)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if searchActive { return }
        
        if moviesArray.count > 0 && indexPath.row >= moviesArray.count - 1 {
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
            
            fetchMovies(page: currentPage + 1)
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
        header.textLabel?.text = "Sorry, there was a network error"
        header.textLabel?.textColor = UIColor.red
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        header.textLabel?.textAlignment = NSTextAlignment.center
    }
    
    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        dlog("")
    }
}

//MARK: - UITableViewDataSource
extension MoviesViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {   if searchActive {
        return filteredMoviesArray.count
        }
        return moviesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MovieSummaryCell") as? MovieSummaryTableViewCell else {
            return UITableViewCell()
        }
        var movieSummary: Movie! = nil
        if searchActive {
            movieSummary = filteredMoviesArray[indexPath.row]
        }
        else {
            movieSummary = moviesArray[indexPath.row]
        }
        cell.movieThumbnailImageView.image = nil
        cell.movieTitleLabel.text = movieSummary.title
        cell.movieOverviewLabel.text = movieSummary.overview
        
        if movieSummary.posterPath.count > 0  {
            let imageUrlString = theMovieDbSecureBaseImageUrl + "/" + poster_sizes[0] + movieSummary.posterPath
            if let imageUrl = URL(string: imageUrlString) {
                let defaultImage = UIImage(named: "default_movie_thumbnail.png")
                
                let urlRequest: URLRequest = URLRequest(url:imageUrl)
                cell.moviePosterUrlString = imageUrlString
                
                cell.movieThumbnailImageView.af_setImage(
                    withURLRequest: urlRequest,
                    placeholderImage: defaultImage,
                    completion:
                    { (response: DataResponse<UIImage>) in
                        
                        if let image: UIImage = response.value
                        {
                            if imageUrlString == cell.moviePosterUrlString {
                                //if response == nil, image came from cache
                                cell.movieThumbnailImageView.alpha = 0.0
                                cell.movieThumbnailImageView.image = image
                                UIView.animate(withDuration: 0.3, animations:
                                    { () -> Void in
                                        cell.movieThumbnailImageView.alpha = 1.0
                                })
                            }
                            else {
                                let defaultImage = UIImage(named: "default_movie_thumbnail.png")
                                cell.movieThumbnailImageView.image = defaultImage
                                dlog("our cell might have been recycled before the image returned, skip")
                            }
                        }
                        else {
                            let defaultImage = UIImage(named: "default_movie_thumbnail.png")
                            cell.movieThumbnailImageView.image = defaultImage
                            dlog("response is not a uiimage")
                        }
                })
            }
            else {
                dlog("bad url: \(imageUrlString)")
                let defaultImage = UIImage(named: "default_movie_thumbnail.png")
                cell.movieThumbnailImageView.image = defaultImage
            }
        }
        else {
            let defaultImage = UIImage(named: "default_movie_thumbnail.png")
            cell.movieThumbnailImageView.image = defaultImage
        }
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
extension MoviesViewController: UIScrollViewDelegate
{
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
extension MoviesViewController: UISearchBarDelegate
{
    /*
     func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
     dlog("")
     searchActive = true
     }
     */
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        dlog("searchText: \(searchText)")
        
        if searchText.count == 0 {
            searchActive = false
            moviesTableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dlog("searchBarText: \(String(describing: searchBar.text))")
        searchBar.endEditing(true)
        
        filteredMoviesArray = moviesArray.filter({ (movie) -> Bool in
            if let searchText = searchBar.text {
                let pattern = "\\b" + searchText + "\\b"
                let range = movie.overview.range(of: pattern, options: [.caseInsensitive, .regularExpression])
                return range != nil
            }
            return false
        })
        //if (filteredMoviesArray.count == 0){
        //    searchActive = false;
        //}
        //else {
        searchActive = true;
        //}
        moviesTableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dlog("")
        searchBar.endEditing(true)
        searchActive = false
        moviesTableView.reloadData()
    }
}
