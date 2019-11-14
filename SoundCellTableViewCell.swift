//
//  SoundCellTableViewCell.swift
//  5140AssignmentStarter
//
//  Created by haofang Liu on 3/11/19.
//  Copyright © 2019 XinzhuoYu. All rights reserved.
//

import UIKit

class SoundCellTableViewCell: UITableViewCell {

    @IBOutlet weak var DateLabel: UILabel!
    
    @IBOutlet weak var DBAndSoundLevelLabe: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
