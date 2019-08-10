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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)

        // Configure the view for the selected state
    }

}
