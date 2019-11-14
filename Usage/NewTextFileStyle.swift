//
//  NewTextFileStyle.swift
//  5140AssignmentStarter
//
//  Created by XinzhuoYu on 16/10/19.
//  Copyright © 2019 XinzhuoYu. All rights reserved.
//

import UIKit

@IBDesignable
class NewTextFileStyle: UITextField {
    
    //Source from: //https://medium.com/bytes-of-bits/swift-tips-adding-rounded-corners-and-shadows-to-a-uiview-691f67b83e4a
    private var shadowLayer: CAShapeLayer!
    private var cornerRadius: CGFloat = 20.0
    private var fillColor: UIColor = .white // the color applied to the shadowLayer, rather than the view's backgroundColor
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
            shadowLayer.fillColor = fillColor.cgColor
            
            shadowLayer.shadowColor = UIColor.black.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 0.5, height: 1.5)
            shadowLayer.shadowOpacity = 0.3
            shadowLayer.shadowRadius = 5
            
            layer.insertSublayer(shadowLayer, at: 0)
        }
        
    }
    //style the button
    static func styleFilledButton(_ button:UIButton) {
        
        // Filled rounded corner style
        button.backgroundColor = UIColor.init(red: 48/255, green: 173/255, blue: 99/255, alpha: 1)
        button.layer.cornerRadius = 25.0
        button.tintColor = UIColor.white
    }
    //get the password to follow rules
    static func isPasswordValid(_ password : String) -> Bool {
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }

}
