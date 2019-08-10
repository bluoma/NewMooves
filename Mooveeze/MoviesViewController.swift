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

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, JsonDownloaderDelegate {

    @IBOutlet weak var moviesTableView: UITableView!
    @IBOutlet weak var moviesSearchBar: UISearchBar!
    
    var jsonDownloader = JsonDownloader()
    var downloadTaskDict: [String:URLSessionDataTask] = [:]
    var moviesArray: [MovieSummary] = []
    var filteredMoviesArray: [MovieSummary] = []
    var endpointPath: String = theMovieDbNowPlayingPath
    var isNetworkErrorShowing: Bool = false
    var header = UITableViewHeaderFooterView()
    var searchActive = false
    var moviesRefreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        moviesRefreshControl = UIRefreshControl()
        moviesRefreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControl.Event.valueChanged)
    
        self.moviesTableView.insertSubview(moviesRefreshControl, at: 0)
        
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        header.addGestureRecognizer(tapRecognizer)
        
        jsonDownloader.delegate = self
        doDownload()
        
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
        
        if let segueId = segue.identifier, segueId == "NowPlayingSummaryToDetailPushSegue" {
            let movieSummary: MovieSummary = sender as! MovieSummary
            let destVc = segue.destination as! MovieDetailViewController
            destVc.movieSummary = movieSummary
        }
    }
    

    
    //MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {   if searchActive {
            return filteredMoviesArray.count
        }
        return moviesArray.count
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieSummaryCell") as! MovieSummaryTableViewCell
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
        cell.movieOverviewLabel.sizeToFit()
        let indexPath = IndexPath(row: 0, section: 0)
        let maxOverviewLabelHeight = self.tableView(self.moviesTableView, heightForRowAt: indexPath) - cell.movieTitleLabel.frame.size.height + 3
        if cell.movieOverviewLabel.frame.size.height > maxOverviewLabelHeight {
            cell.movieOverviewLabel.frame.size.height = maxOverviewLabelHeight
        }
        
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
                        dlog("got imagewrapper: \(type(of: response)) for indexPath: \(indexPath), response: \(response)")
                        
                        if let image: UIImage = response.value
                        {
                            if imageUrlString == cell.moviePosterUrlString {
                                //if response == nil, image came from cache
                                dlog("response.response: \(String(describing: response.response))")
                                cell.movieThumbnailImageView.alpha = 0.0;
                                cell.movieThumbnailImageView.image = image
                                UIView.animate(withDuration: 0.3, animations:
                                { () -> Void in
                                    cell.movieThumbnailImageView.alpha = 1.0
                                })
                            }
                            else {
                                dlog("our cell might have been recycled before the image returned, skip")
                            }
                        }
                        else {
                            dlog("response is not a uiimage")
                        }
                    })
                
                /*
                cell.movieThumbnailImageView.setImageWith(_:urlRequest, placeholderImage: nil,
                    success: { (request: URLRequest, response:HTTPURLResponse?, image: UIImage) -> Void in
                        //dlog("got image: \(image) for indexPath: \(indexPath), response: \(response)")
                        if imageUrlString == cell.moviePosterUrlString {
                            //if response == nil, image came from cache
                            if (response != nil) {
                                cell.movieThumbnailImageView.alpha = 0.0;
                                cell.movieThumbnailImageView.image = image
                                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                                    cell.movieThumbnailImageView.alpha = 1.0
                                })
                            }
                            else {
                                cell.movieThumbnailImageView.image = image
                            }
                        }
                        else {
                            dlog("our cell might have been recycled before the image returned, skip")
                        }
                    },
                    failure: { (request: URLRequest, response: HTTPURLResponse?, error: Error) -> Void in
                        dlog("image fetch failed: \(error) for indexPath: \(indexPath)")
                        cell.movieThumbnailImageView.image = defaultImage
                    })
                    */
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
    
    @objc func handleTap(gestureRecognizer: UIGestureRecognizer)
    {
        dlog("Header Tapped")
        isNetworkErrorShowing = !isNetworkErrorShowing
        moviesTableView.reloadData()
    }
    
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 96.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        dlog("row: \(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: true)
        
        var movieSummary: MovieSummary! = nil
        if searchActive {
            movieSummary = filteredMoviesArray[indexPath.row]
        }
        else {
            movieSummary = moviesArray[indexPath.row]
        }
        self.performSegue(withIdentifier: "NowPlayingSummaryToDetailPushSegue", sender: movieSummary)
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
    
    //MARK: - UISearchBarDelegate
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
    
    //MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //dlog("contentSize: \(scrollView.contentSize), contentOffset: \(scrollView.contentOffset)")
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        //dlog("contentSize: \(scrollView.contentSize), contentOffset: \(scrollView.contentOffset)")
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //dlog("contentSize: \(scrollView.contentSize), contentOffset: \(scrollView.contentOffset)")
    }

    
    //MARK: - JsonDownloader
    
    @objc func refreshControlAction(refreshControl: UIRefreshControl) {
        dlog("");
        //refreshControl.endRefreshing()
        doDownload()
    }

    
    func doDownload() {
        let currentlyPlayingUrlString = theMovieDbSecureBaseUrl + endpointPath + "?" + theMovieDbApiKeyParam
        cancelJsonDownloadTask(urlString: currentlyPlayingUrlString)
        if let task: URLSessionDataTask = jsonDownloader.doDownload(urlString: currentlyPlayingUrlString) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            downloadTaskDict[currentlyPlayingUrlString] = task
        }

    }
    
    func jsonDownloaderDidFinish(downloader: JsonDownloader, json: [String:AnyObject]?, response: HTTPURLResponse, error: NSError?)
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        if moviesRefreshControl.isRefreshing {
            moviesRefreshControl.endRefreshing()
        }
        if error != nil {
            dlog("err: \(String(describing: error))")
            isNetworkErrorShowing = true
            moviesTableView.reloadData()
        }
        else {
            dlog("got json")
            
            if let jsonObj: [String:AnyObject]  = json,
                let results: [AnyObject] = jsonObj["results"] as? [AnyObject] {
                var resultsArray: [MovieSummary] = []
                
                for movieObj in results {
                    let movieDict: NSDictionary = movieObj as! NSDictionary
                    let movieDto: MovieSummary = MovieSummary(jsonDict: movieDict)
                    //dlog("movieDTO: \(movieDto)")
                    resultsArray.append(movieDto)
                }
                moviesArray = resultsArray
                isNetworkErrorShowing = false
                moviesTableView.reloadData()
            }
            else {
                dlog("no json")
                isNetworkErrorShowing = true
                moviesTableView.reloadData()
            }
        }
        if let urlString = response.url?.absoluteString {
            dlog("url from response: \(urlString)")
            downloadTaskDict[urlString] = nil
        }
    }
    
    func cancelJsonDownloadTask(urlString: String)
    {
        if let currentDowloadTask: URLSessionDataTask = downloadTaskDict[urlString] {
            currentDowloadTask.cancel()
            downloadTaskDict[urlString] = nil
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }

    }
    
    func cancelAllJsonDownloadTasks()
    {
        for (_, task) in downloadTaskDict {
            task.cancel()
        }
        downloadTaskDict.removeAll()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }

    

}
