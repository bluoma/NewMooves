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
    var viewModel: MovieDetailViewModel!
    
    var didSelectVideo: ((Int, Movie) -> Void)?
    
    var dynamicMovieDetail: DynamicMovieDetail? {
        
        didSet {
            guard let dynDetail = dynamicMovieDetail else { return }
            
            dynDetail.title.bindAndFire {
                [unowned self] (movieTitle: String) in
                dlog("title bind: \(movieTitle)")
                self.title = movieTitle
            }
            dynDetail.overview.bindAndFire {
                [unowned self] (overview: String) in
                dlog("overview bind: \(overview)")
                self.overviewLabel.text = overview
                self.overviewLabel.sizeToFit()
            }
            dynDetail.selectedGenre.bindAndFire {
                [unowned self] (selectedGenre: String) in
                dlog("selectedGenre bind: \(selectedGenre)")
                self.genreLabel.text = selectedGenre
            }
            dynDetail.voteAverage.bindAndFire {
                [unowned self] (voteAverage: Double) in
                self.ratingLabel.text = String(voteAverage) + " / 10.00"
            }
            dynDetail.releaseDate.bindAndFire {
                [unowned self] (releaseDate: Date) in
                dlog("releaseDate bind: \(releaseDate)")
                self.releaseDateLabel.text = self.dateFormatter.string(from: releaseDate)
            }
            dynDetail.tagline.bindAndFire {
                [unowned self] (tagline: String) in
                dlog("tagline bind: \(tagline)")
                self.titleLabel.text = tagline
            }
            dynDetail.runtime.bindAndFire {
                [unowned self] (runtime: Int) in
                if runtime > 0 {
                    let hours = runtime / 60
                    let minutes = runtime % 60
                    let runttimeString = "\(hours) hr \(minutes) min"
                    self.runningTimeLabel.text = runttimeString
                }
                else {
                    self.runningTimeLabel.text = ""
                }
            }
        }
    }
    
    deinit {
        dlog("deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let foundMovie = movie else {
            assert(false, "no movie found in viewDidLoad")
            return
        }
        dateFormatter.dateStyle = .medium

        viewModel = MovieDetailViewModel(movie: foundMovie)
        dynamicMovieDetail = viewModel.dynamicMovieDetail
        
        
        contentScrollView.contentSize = CGSize(width: contentScrollView.frame.size.width, height: bottomContainerView.frame.origin.y + bottomContainerView.frame.size.height)
        
        if let posterPath = foundMovie.posterPath, posterPath.count > 0  {
            let imageUrlString = Constants.theMovieDbSecureBaseImageUrl + "/" + Constants.poster_sizes[4] + posterPath
            if let imageUrl = URL(string: imageUrlString) {
                let defaultImage = UIImage(named: "default_poster_image.png")
                let urlRequest: URLRequest = URLRequest(url: imageUrl)
                
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
    /*
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView === videosTableView {
            dlog("tableView contentSize: \(scrollView.contentSize), contentOffset: \(scrollView.contentOffset)")
        }
        else {
            dlog("contentSize: \(scrollView.contentSize), contentOffset: \(scrollView.contentOffset)")
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView === videosTableView {
            dlog("tableView contentSize: \(scrollView.contentSize), contentOffset: \(scrollView.contentOffset)")
        }
        else {
            dlog("contentSize: \(scrollView.contentSize), contentOffset: \(scrollView.contentOffset)")
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView === videosTableView {
            dlog("tableView contentSize: \(scrollView.contentSize), contentOffset: \(scrollView.contentOffset)")
        }
        else {
            dlog("contentSize: \(scrollView.contentSize), contentOffset: \(scrollView.contentOffset)")
        }
    }
    */
    
    //MARK: - Network
    func fetchMovieDetail() {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        moviesService.fetchMovieDetail(byId: movie.movieId, completion:
        { [weak self] (detail: MovieDetail?, error: Error?) -> Void in
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            guard let myself = self else { return }
            
            if let detail = detail {
                myself.movie.movieDetail = detail
                myself.displayMovieDetails(detail: detail)
            }
            else if let error = error {
                dlog("err: \(String(describing: error))")
            }
            else {
                assert(false, "error and detail are nil")
            }
        })
    }
    
    func fetchMovieVideos() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        moviesService.fetchMovieVideos(byId: movie.movieId, completion:
        { [weak self] (videos: [MovieVideo], error: Error?) -> Void in
            
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
        dlog("")
        guard let detail = detail else {
            //TODO handle empty state
            return
        }
        
        dynamicMovieDetail?.runtime.value = detail.runtime
        dynamicMovieDetail?.tagline.value = detail.tagline
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            [weak self] in
            guard let myself = self else { return }
            myself.scrollToView(myself.contentScrollView, target: myself.bottomContainerView, animated: true)
        }
        
    }
    
    func scrollToView(_ scrollView: UIScrollView, target: UIView, animated: Bool) {
        if let originView = target.superview {
            // Get the Y position of your child view
            let childStartPoint = originView.convert(target.frame.origin, to: scrollView)
            // Scroll to a rectangle starting at the Y of your subview, with a height of the scrollview
            scrollView.scrollRectToVisible(CGRect(x: 0, y: childStartPoint.y, width: 1, height: scrollView.frame.height), animated: animated)
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
