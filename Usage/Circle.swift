//
//  Circle.swift
//  5140AssignmentStarter
//
//  Created by haofang Liu on 29/10/19.
//  Copyright © 2019 XinzhuoYu. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    //get the round ui image
    func makeRounded() {
        
        self.layer.borderWidth = 1
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
}
