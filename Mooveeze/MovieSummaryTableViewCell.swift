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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .default
        selectedBackgroundView = UIView(frame: frame)
        selectedBackgroundView?.backgroundColor = UIColor(red: 0.5, green: 0.7, blue: 0.9, alpha: 0.8)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
      
    }


}
