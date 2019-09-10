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

class MovieDetailViewController: UIViewController, UIScrollViewDelegate {
    
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
    var movie: Movie!
    let moviesService = MoviesService()
    
    var didSelectVideo: ((Int, Movie) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.title = movie.title
        
        titleLabel.text = ""
        runningTimeLabel.text = ""
        ratingLabel.text = ""
        genreLabel.text = ""
        runningTimeLabel.text = ""
        releaseDateLabel.text = ""
        
        overviewLabel.text = movie.overview
        overviewLabel.sizeToFit()
        
        ratingLabel.text = String(movie.voteAverage) + " / 10.00"
        dateFormatter.dateStyle = .medium
        releaseDateLabel.text = dateFormatter.string(from: movie.releaseDate)
        
        
        contentScrollView.contentSize = CGSize(width: contentScrollView.frame.size.width, height: bottomContainerView.frame.origin.y + bottomContainerView.frame.size.height)
        
        if let posterPath = movie.posterPath, posterPath.count > 0  {
            let imageUrlString = Constants.theMovieDbSecureBaseImageUrl + "/" + Constants.poster_sizes[4] + posterPath
            if let imageUrl = URL(string: imageUrlString) {
                let defaultImage = UIImage(named: "default_poster_image.png")
                let urlRequest: URLRequest = URLRequest(url:imageUrl)
                
                backdropImageView.af_setImage(
                    withURLRequest: urlRequest,
                    placeholderImage: defaultImage,
                    completion:
                    { [weak self] (response: DataResponse<UIImage>) in
                        guard let myself = self else { return }
                        dlog("got imagewrapper: \(type(of: response)), response: \(response)")
                        
                        if let image: UIImage = response.value {
                            myself.backdropImageView.alpha = 0.0;
                            myself.backdropImageView.image = image
                            UIView.animate(withDuration: 0.3, animations:
                            { () -> Void in
                                myself.backdropImageView.alpha = 1.0
                            })
                        }
                        else {
                            dlog("response is not a uiimage")
                        }
                    }
                )
            }
            else {
                dlog("bad url for image: \(imageUrlString)")
                let defaultImage = UIImage(named: "default_poster_image.png")
                self.backdropImageView.image = defaultImage
            }
        }
        else {
            dlog("no url for posterPath: \(String(describing: movie.posterPath))")
            let defaultImage = UIImage(named: "default_poster_image.png")
            self.backdropImageView.image = defaultImage
        }
        
        
        
        if let movieDetails = movie.movieDetail {
            displayMovieDetails(detail: movieDetails)
        }
        else {
            fetchMovieDetail()
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
        
        if movie.movieVideos.isEmpty {
            fetchMovieVideos()
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
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    
    //MARK: - Network
    func fetchMovieDetail() {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        moviesService.fetchMovieDetail(byId: movie.movieId, completion:
        { [weak self] (detail: MovieDetail?, error: NSError?) -> Void in
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            guard let myself = self else { return }
            
            if error != nil {
                dlog("err: \(String(describing: error))")
                myself.movie.movieDetail = detail
                myself.displayMovieDetails(detail: detail)
            }
            else {
                myself.movie.movieDetail = detail
            }
        })
    }
    
    func fetchMovieVideos() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        moviesService.fetchMovieVideos(byId: movie.movieId, completion:
        { [weak self] (videos: [MovieVideo], error: NSError?) -> Void in
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            guard let myself = self else { return }
            
            if error != nil {
                dlog("err: \(String(describing: error))")
            }
            else {
                myself.movie.movieVideos = videos
                myself.videosTableView.reloadData()
            }
        })
    }
    
    func displayMovieDetails(detail: MovieDetail?) -> Void {
        
        guard let details = detail else {
            //TODO handle empty state
            return
        }
        
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
        if movie.genreNames.count > 0 {
            genreLabel.text = movie.genreNames.first
        }
    }
}

//MARK: - UITableViewDataSource
extension MovieDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movie.movieVideos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = String(describing: MovieDetailVideoTableViewCell.self)
        
        guard let videoCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MovieDetailVideoTableViewCell else {
                return UITableViewCell()
        }
        
        let video = movie.movieVideos[indexPath.row]
        
        videoCell.videoSiteLabel.text = video.site + " " + video.type
        videoCell.videoTitleLabel.text = video.name
        
        return videoCell
    }
}

//MARK: - UITableViewDataDelegate
extension MovieDetailViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dlog("row: \(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.didSelectVideo?(indexPath.row, self.movie)
    }
    
}
