//
//  MovieDetailVideoTableViewCell.swift
//  Mooveeze
//
//  Created by Bill on 8/9/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import UIKit

class MovieDetailVideoTableViewCell: UITableViewCell {

    @IBOutlet var videoSiteLabel: UILabel!
    @IBOutlet var videoTitleLabel: UILabel!

    var dynamicMovieVideo: DynamicMovieVideo? {
        
        didSet {
            guard let dynVid = dynamicMovieVideo else {
                videoSiteLabel.text = ""
                videoTitleLabel.text = ""
                return
            }
            dynVid.name.bindAndFire {
                [weak self] (name: String) in
                self?.videoTitleLabel.text = name
            }
            dynVid.site.bindAndFire {
                [weak self] (site: String) in
                self?.videoSiteLabel.text = site
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.videoSiteLabel.backgroundColor = .clear
        self.videoTitleLabel.backgroundColor = .clear
        self.videoSiteLabel.textColor = .white
        self.videoTitleLabel.textColor = .white

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        videoSiteLabel.text = ""
        videoTitleLabel.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
