//
//  TimerTableViewCell.swift
//  Pi-Heating
//
//  Created by Timothy Barnard on 04/05/2016.
//  Copyright © 2016 Timothy Barnard. All rights reserved.
//

import UIKit

class TimerTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var ipadTimerType: UILabel!
    @IBOutlet weak var ipadTimerStart: UILabel!
    @IBOutlet weak var ipadTimerEnd: UILabel!
    
    @IBOutlet weak var timerType: UILabel!
    @IBOutlet weak var timerStart: UILabel!
    @IBOutlet weak var timerEnd: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
