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

class MovieViewController: UIViewController, UIScrollViewDelegate {
    
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

    let moviesService = MovieService()
    //injected by coordinator
    var viewModel: MovieViewModel!
    var dynamicMovie: DynamicMovie? {
        
        didSet {
            guard let dynDetail = dynamicMovie else { return }
            
            dynDetail.title.bindAndFire {
                [unowned self] (movieTitle: String) in
                //dlog("title bind: \(movieTitle)")
                self.title = movieTitle
            }
            dynDetail.overview.bindAndFire {
                [unowned self] (overview: String) in
                //dlog("overview bind: \(overview)")
                self.overviewLabel.text = overview
                self.overviewLabel.sizeToFit()
            }
            dynDetail.selectedGenre.bindAndFire {
                [unowned self] (selectedGenre: String) in
                //dlog("selectedGenre bind: \(selectedGenre)")
                self.genreLabel.text = selectedGenre
            }
            dynDetail.voteAverage.bindAndFire {
                [unowned self] (voteAverage: Double) in
                self.ratingLabel.text = String(voteAverage) + " / 10.00"
            }
            dynDetail.releaseDate.bindAndFire {
                [unowned self] (releaseDate: String) in
                //dlog("releaseDate bind: \(releaseDate)")
                self.releaseDateLabel.text = releaseDate
            }
            dynDetail.tagline.bindAndFire {
                [unowned self] (tagline: String) in
                //dlog("tagline bind: \(tagline)")
                self.titleLabel.text = tagline
            }
            dynDetail.runtimeString.bindAndFire {
                [unowned self] (runtimeString: String) in
                if !runtimeString.isEmpty {
                    self.runningTimeLabel.text = runtimeString
                    self.displayMovieDetails()
                }
            }
            dynDetail.backdropImage.bindAndFire {
                [unowned self] (image: UIImage?) in
                //dlog("backdropImage bind: \(String(describing: image))")
                self.backdropImageView.image = image
            }
            dynDetail.videosLoaded.bindAndFire {
                [unowned self] (videosLoaded: Bool) in
                if videosLoaded {
                    self.videosTableView.reloadData()
                }
            }
        }
    }
    
    var didSelectVideo: ((MovieVideo) -> Void)?
    
    deinit {
        dlog("deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentScrollView.contentSize = CGSize(width: contentScrollView.frame.size.width, height: bottomContainerView.frame.origin.y + bottomContainerView.frame.size.height)
        
        
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
    
        dynamicMovie = viewModel.dynamicMovie
        
        viewModel.fetchBackdropImage()
        viewModel.fetchMovieDetail()
        viewModel.fetchMovieVideos()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dlog("")
        let blur = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = self.bottomContainerView.bounds
        self.bottomContainerView.backgroundColor = .clear
        self.bottomContainerView.insertSubview(blurView, at: 0)
        self.bottomContainerView.alpha = 0.75
        self.bottomContainerView.layer.cornerRadius = 4
        self.bottomContainerView.layer.masksToBounds = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dlog("")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayMovieDetails() {
        dlog("")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            [weak self] in
            guard let myself = self else { return }
            
            let childStartPoint = myself.contentScrollView.convert(myself.bottomContainerView.frame.origin, to: myself.contentScrollView)
            myself.contentScrollView.scrollRectToVisible(CGRect(x: 0, y: childStartPoint.y, width: 1, height: myself.contentScrollView.frame.height), animated: true)
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
extension MovieViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.videoCellCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = String(describing: MovieDetailVideoTableViewCell.self)
        
        guard let videoCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MovieDetailVideoTableViewCell else {
                return UITableViewCell()
        }
        
        let videoViewModel = viewModel.videoCellViewModel(at: indexPath)
        videoCell.dynamicMovieVideo = videoViewModel.dynamicMovieVideo
        
        return videoCell
    }
}

//MARK: - UITableViewDataDelegate
extension MovieViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dlog("row: \(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let movieVideo = viewModel.selectedMovieVideo(at: indexPath) {
            self.didSelectVideo?(movieVideo)
        }
    }
    
}
