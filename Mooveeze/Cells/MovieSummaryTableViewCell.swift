//
//  MovieSummaryTableViewCell.swift
//  Mooveeze
//
//  Created by Bill on 10/7/16.
//  Copyright © 2016 Bill. All rights reserved.
//

import UIKit

class MovieSummaryTableViewCell: UITableViewCell {

    @IBOutlet weak var movieThumbnailImageView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieOverviewLabel: UILabel!
    
    var moviePosterUrlString: String!
    var dynamicMovie: DynamicMovie? {
        
        didSet {
            guard let dynMovie = dynamicMovie else {
                movieThumbnailImageView.image = nil
                movieTitleLabel.text = nil
                movieOverviewLabel.text = nil
                return
            }
            dynMovie.title.bindAndFire {
                [weak self] (title: String) in
                self?.movieTitleLabel.text = title
            }
            dynMovie.overview.bindAndFire {
                [weak self] (overview: String) in
                self?.movieOverviewLabel.text = overview
            }
            dynMovie.backdropImage.bindAndFire {
                [weak self] (image: UIImage?) in
                if let image = image {
                    self?.movieThumbnailImageView.alpha = 0.0
                    self?.movieThumbnailImageView.image = image
                    let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut) {
                        self?.movieThumbnailImageView.alpha = 1.0
                    }
                    animator.startAnimation()
                }
                else {
                    dlog("thumbnail bind image is nil")
                }
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .default
        selectedBackgroundView = UIView(frame: frame)
        selectedBackgroundView?.backgroundColor = UIColor(red: 0.5, green: 0.7, blue: 0.9, alpha: 0.8)
        
        
        movieThumbnailImageView.layer.cornerRadius = 8
        movieThumbnailImageView.layer.masksToBounds = true
        movieThumbnailImageView.image = UIImage(named: "default_movie_thumbnail.png")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        //animator.stopAnimation(true)
        movieThumbnailImageView.alpha = 1.0
        movieThumbnailImageView.image = UIImage(named: "default_movie_thumbnail.png")
        movieTitleLabel.text = nil
        movieOverviewLabel.text = nil
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
      
    }


}
