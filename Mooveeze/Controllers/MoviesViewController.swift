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
    
    var jsonDownloader = JsonDownloader()
    var downloadTaskDict: [String:URLSessionDataTask] = [:]
    var moviesArray: [MovieSummary] = []
    var filteredMoviesArray: [MovieSummary] = []
    var endpointPath: String = ""
    var isNetworkErrorShowing: Bool = false
    var header = UITableViewHeaderFooterView()
    var searchActive = false
    var moviesRefreshControl: UIRefreshControl!
    var downloadIsInProgress: Bool = false
    var totalPages: Int = 0
    var currentPage: Int = 1
    var totalCount: Int = 0
    
    var didSelectDetail: ((MovieSummary) -> Void)?
    
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
        
        self.doMoviesDownload(page: currentPage)
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
        cancelAllJsonDownloadTasks()
    }


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        //NowPlayingSummaryToDetailPushSegue
        
        dlog("segue: \(String(describing: segue.identifier)) sender: \(String(describing: sender))")
        guard let segueId = segue.identifier else {
            return
        }
        
        if segueId == "NowPlayingSummaryToDetailPushSegue",
            let movieSummary: MovieSummary = sender as? MovieSummary,
            let destVc = segue.destination as? MovieDetailViewController {
                destVc.movieSummary = movieSummary
            self.navigationController?.show(destVc, sender: self)
        }
    }
    
    @objc func handleTap(gestureRecognizer: UIGestureRecognizer)
    {
        dlog("Header Tapped")
        isNetworkErrorShowing = !isNetworkErrorShowing
        moviesTableView.reloadData()
    }
    
    //MARK: - JsonDownloader
    @objc func refreshControlAction(refreshControl: UIRefreshControl) {
        dlog("");
        if searchActive {
            searchActive = false
            moviesSearchBar.endEditing(true)
            moviesTableView.reloadData()
        }
        if downloadIsInProgress { return }
        currentPage = 1
        doMoviesDownload(page: 1)
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
    
    fileprivate func doMoviesDownload(page: Int = 1) {
        
        if downloadIsInProgress || searchActive { return }
        if page > 1 && page >= totalPages { return }
        
        isNetworkErrorShowing = false
        header.textLabel?.text = ""
        downloadIsInProgress = true
        beginDownload()
        
        let currentlyPlayingUrlString = theMovieDbSecureBaseUrl + endpointPath + "?" + theMovieDbApiKeyParam + "&page=" + String(page)
        cancelJsonDownloadTask(urlString: currentlyPlayingUrlString)

        if let task: URLSessionDataTask = jsonDownloader.doDownload(
            urlString: currentlyPlayingUrlString,
            completion:
            { [weak self] (json: [String:AnyObject]?, response: HTTPURLResponse?, error: NSError?) in
                guard let weakself = self else { return }
                
                weakself.endDownload()
                weakself.downloadIsInProgress = false
                
                if error != nil {
                    dlog("err: \(String(describing: error))")
                    weakself.isNetworkErrorShowing = true
                    weakself.moviesTableView.reloadData()
                }
                else {
                    
                    if let jsonObj = json,
                        let results = jsonObj["results"] as? NSArray {
                        var resultsArray: [MovieSummary] = []
                        
                        if let count = jsonObj["total_results"] as? Int {
                            weakself.totalCount = count
                        }
                        
                        if let pageCount = jsonObj["total_pages"] as? Int {
                            weakself.totalPages = pageCount
                        }
                        
                        if let page = jsonObj["page"] as? Int {
                            if page != weakself.currentPage {
                                dlog("page: \(page) != currentPage: \(weakself.currentPage)")
                            }
                        }
                        
                        dlog("got json for page: \(weakself.currentPage) of: \(weakself.totalPages) for: \(weakself.totalCount) movie summaries")
                        
                        for movieObj in results {
                            if let movieDict: NSDictionary = movieObj as? NSDictionary{
                                let movieSummary: MovieSummary = MovieSummary(jsonDict: movieDict)
                                resultsArray.append(movieSummary)
                                dlog("summary: \(movieSummary.title), genres: \(movieSummary.genreNames)")
                            }
                        }
                        weakself.currentPage = page

                        if weakself.currentPage > 1 {
                            weakself.moviesArray += resultsArray
                        }
                        else {
                            weakself.moviesArray = resultsArray
                        }
                        weakself.moviesTableView.reloadData()
                    }
                    else {
                        dlog("no json")
                        weakself.isNetworkErrorShowing = true
                        weakself.moviesTableView.reloadData()
                    }
                }
                if let foundResponse = response, let urlString = foundResponse.url?.absoluteString {
                    dlog("remove task url from dict: \(urlString)")
                    weakself.downloadTaskDict[urlString] = nil
                }
            })
            {
                downloadTaskDict[currentlyPlayingUrlString] = task
                task.resume()
            }
    }
    
    fileprivate func cancelJsonDownloadTask(urlString: String)
    {
        if let currentDowloadTask: URLSessionDataTask = downloadTaskDict[urlString] {
            currentDowloadTask.cancel()
            downloadTaskDict[urlString] = nil
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }

    }
    
    fileprivate func cancelAllJsonDownloadTasks()
    {
        for (_, task) in downloadTaskDict {
            task.cancel()
        }
        downloadTaskDict.removeAll()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
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
        
        var movieSummary: MovieSummary!
        if searchActive {
            movieSummary = filteredMoviesArray[indexPath.row]
        }
        else {
            movieSummary = moviesArray[indexPath.row]
        }
        self.didSelectDetail?(movieSummary)
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
            
            doMoviesDownload(page: currentPage + 1)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        dlog("");
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
        var movieSummary: MovieSummary! = nil
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
