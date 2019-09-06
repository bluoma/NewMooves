//
//  MovieDetailViewController.swift
//  Mooveeze
//
//  Created by Bill on 10/7/16.
//  Copyright © 2016 Bill. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class MovieDetailViewController: UIViewController, UIScrollViewDelegate, JsonDownloaderDelegate {

    enum DownloadType: String
    {
        case movieDetail = "movieDetail"
        case movieVideos = "movieVideos"
    }
    
    @IBOutlet weak var backdropImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var bottomContainerView: UIView!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var runningTimeLabel: UILabel!
    @IBOutlet weak var videosTableView: UITableView!

    var dateFormatter = DateFormatter()
    var movieSummary: MovieSummary!
    
    var didSelectVideo: ((Int, MovieSummary) -> Void)?
    
    var jsonDownloader = JsonDownloader()
    var downloadTaskDict: [String: URLSessionDataTask] = [:]
    let videoSegueIdentifier = "DetailToVideoPushSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.title = movieSummary.title
        
        titleLabel.text = ""
        runningTimeLabel.text = ""
        ratingLabel.text = ""
        genreLabel.text = ""
        runningTimeLabel.text = ""
        releaseDateLabel.text = ""
        
        overviewLabel.text = movieSummary.overview
        overviewLabel.sizeToFit()
        
        ratingLabel.text = String(movieSummary.voteAverage) + " / 10.00"
        if let releaseDate = movieSummary.releaseDate {
            dateFormatter.dateStyle = .medium
            releaseDateLabel.text = dateFormatter.string(from: releaseDate)
        }
        
        contentScrollView.contentSize = CGSize(width: contentScrollView.frame.size.width, height: bottomContainerView.frame.origin.y + bottomContainerView.frame.size.height)
        
        if movieSummary.posterPath.count > 0  {
            let imageUrlString = theMovieDbSecureBaseImageUrl + "/" + poster_sizes[4] + movieSummary.posterPath
            if let imageUrl = URL(string: imageUrlString) {
                let defaultImage = UIImage(named: "default_poster_image.png")
                let urlRequest: URLRequest = URLRequest(url:imageUrl)
                
                backdropImageView.af_setImage(
                    withURLRequest: urlRequest,
                    placeholderImage: defaultImage,
                    completion:
                    { (response: DataResponse<UIImage>) in
                        dlog("got imagewrapper: \(type(of: response)), response: \(response)")
                        
                        if let image: UIImage = response.value
                        {
                            self.backdropImageView.alpha = 0.0;
                            self.backdropImageView.image = image
                            UIView.animate(withDuration: 0.3, animations:
                            { () -> Void in
                                self.backdropImageView.alpha = 1.0
                            })
                        }
                        else {
                            dlog("response is not a uiimage")
                        }
                })
            }
            else {
                dlog("bad url for image: \(imageUrlString)")
                let defaultImage = UIImage(named: "default_poster_image.png")
                self.backdropImageView.image = defaultImage
            }
        }
        else {
            dlog("no url for posterPath: \(movieSummary.posterPath)")
            let defaultImage = UIImage(named: "default_poster_image.png")
            self.backdropImageView.image = defaultImage
        }
        
        
        
        if let movieDetails = movieSummary.movieDetail {
            displayMovieDetails(details: movieDetails)
        }
        else {
            jsonDownloader.delegate = self
            doDownload()
        }
        self.videosTableView.backgroundColor = .clear
        self.videosTableView.separatorStyle = .singleLine
        self.videosTableView.separatorColor  = .white
        self.videosTableView.separatorInset = .zero
        self.videosTableView.tableFooterView = UIView()
        
        let blur = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = self.videosTableView.bounds
        blurView.alpha = 0.75
        self.videosTableView.backgroundView = blurView
        
        if movieSummary.movieVideos.isEmpty
        {
            doVideoDownload()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let blur = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = self.bottomContainerView.bounds
        self.bottomContainerView.backgroundColor = .clear
        self.bottomContainerView.insertSubview(blurView, at: 0)
        self.bottomContainerView.alpha = 0.75
        self.bottomContainerView.layer.cornerRadius = 4
        self.bottomContainerView.layer.masksToBounds = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cancelAllJsonDownloadTasks()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        guard let segueIdentifier = segue.identifier else { return }
        
        if segueIdentifier == self.videoSegueIdentifier, let indexPath = sender as? IndexPath,
            let dest = segue.destination as? MovieVideoWebViewController {
            
            dest.videoIndex = indexPath.row
            dest.movieSummary = self.movieSummary
            
        }
    }
    

        
    //MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //dlog("contentSize: \(scrollView.contentSize), contentOffset: \(scrollView.contentOffset)")
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        dlog("contentSize: \(scrollView.contentSize), contentOffset: \(scrollView.contentOffset)")
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        dlog("contentSize: \(scrollView.contentSize), contentOffset: \(scrollView.contentOffset)")
    }
    
    
    //MARK: - JsonDownloader
    
    func doDownload() {
        let baseUrl = theMovieDbSecureBaseUrl + theMovieDbMovieDetailPath + "/"
        let movieDetailUrlString = baseUrl + String(movieSummary.movieId) + "?" + theMovieDbApiKeyParam
        cancelJsonDownloadTask(urlString: movieDetailUrlString)
        if let task: URLSessionDataTask = jsonDownloader.doDownload(urlString: movieDetailUrlString) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            task.taskDescription = DownloadType.movieDetail.rawValue
            downloadTaskDict[movieDetailUrlString] = task
        }
        
    }
    
    func doVideoDownload() {
        let baseUrl = theMovieDbSecureBaseUrl + theMovieDbMovieDetailPath + "/"
        let movieVideoUrlString = baseUrl + String(movieSummary.movieId) + theMovieDbMovieVideoPath + "?" + theMovieDbApiKeyParam
        cancelJsonDownloadTask(urlString: movieVideoUrlString)
        if let task: URLSessionDataTask = jsonDownloader.doDownload(urlString: movieVideoUrlString) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            task.taskDescription = DownloadType.movieVideos.rawValue
            downloadTaskDict[movieVideoUrlString] = task
        }
        
    }
    
    func jsonDownloaderDidFinish(downloader: JsonDownloader, json: [String: AnyObject]?, response: HTTPURLResponse, error: NSError?)
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        guard let urlString = response.url?.absoluteString,
            let task = downloadTaskDict[urlString] else {
            dlog("no url/task from response: \(response)")
            return
        }
        
        dlog("url from response: \(urlString)")
        
        
        if error != nil {
            dlog("err: \(String(describing: error))")
            
        }
        else {
                    
            if let jsonObj: [String:AnyObject] = json,
                let taskDescription = task.taskDescription,
                let downloadType = DownloadType(rawValue: taskDescription) {
                dlog("jsonObj: \(type(of:jsonObj)), type: \(downloadType)")
                
                switch downloadType
                {
                case .movieDetail:
                    let movieDetail = MovieDetail(jsonDict: jsonObj as NSDictionary)
                    
                    dlog("movieDetail: \(movieDetail)")
                    
                    self.movieSummary.movieDetail = movieDetail
                    self.displayMovieDetails(details: movieDetail)
                    
                case .movieVideos:
                    let movieVideosWrapper = jsonObj as NSDictionary
                    if let videos = movieVideosWrapper["results"] as? NSArray {
                    
                        dlog("movieVIdeos: \(videos)")
                        var videoArray: [MovieVideo] = []
                        for videoJson in videos {
                            if let videoDict = videoJson as? NSDictionary {
                                let video = MovieVideo(jsonDict: videoDict)
                                videoArray.append(video)
                            }
                        }
                        if !videoArray.isEmpty {
                            self.movieSummary.movieVideos = videoArray
                            dlog("videoArray: \(videoArray)")
                            self.videosTableView.reloadData()
                        }
                    }
                }
            }
            else {
                dlog("no json or task description")
                
            }
        }
        downloadTaskDict[urlString] = nil
        
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
    
    func displayMovieDetails(details: MovieDetail) -> Void {
        
        if details.runtime > 0 {
            let hours = details.runtime / 60
            let minutes = details.runtime % 60
            let runttimeString = "\(hours) hr \(minutes) min"
            runningTimeLabel.text = runttimeString
        }
        
        if details.tagline.count > 0 {
            titleLabel.alpha = 0.0;
            titleLabel.text = details.tagline
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.titleLabel.alpha = 1.0
            })
        }
        if details.genres.count > 0 {
            genreLabel.text = details.genres.first
        }
    }
}

//MARK: - UITableViewDataSource
extension MovieDetailViewController: UITableViewDataSource
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let summary = self.movieSummary {
            return summary.movieVideos.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellIdentifier = String(describing: MovieDetailVideoTableViewCell.self)
        
        guard let summary = self.movieSummary,
            let videoCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MovieDetailVideoTableViewCell else {
                return UITableViewCell()
        }
        
        let video = summary.movieVideos[indexPath.row]
        
        videoCell.videoSiteLabel.text = video.site + " " + video.type
        videoCell.videoTitleLabel.text = video.name
        
        return videoCell
    }
}

//MARK: - UITableViewDataDelegate
extension MovieDetailViewController: UITableViewDelegate
{

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 64.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        dlog("row: \(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.didSelectVideo?(indexPath.row, self.movieSummary)
        
    }
    
}
