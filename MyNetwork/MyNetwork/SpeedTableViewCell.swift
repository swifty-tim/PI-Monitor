//
//  SpeedTableViewCell.swift
//  MyNetwork
//
//  Created by Timothy Barnard on 17/04/2016.
//  Copyright © 2016 Timothy Barnard. All rights reserved.
//

import UIKit

class SpeedTableViewCell: UITableViewCell {

  
    @IBOutlet weak var cellHeader: UILabel!
    @IBOutlet weak var cellLeftTop: UILabel!
    @IBOutlet weak var cellLeftBottom: UILabel!
    @IBOutlet weak var cellRightTop: UILabel!
    @IBOutlet weak var cellRightBottom: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
