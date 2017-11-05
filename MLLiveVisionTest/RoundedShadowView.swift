//
//  RoundedShadowView.swift
//  Visionary
//
//  Created by Thijs van der Heijden on 11/5/17.
//  Copyright © 2017 Thijs van der Heijden. All rights reserved.
//

import UIKit

class RoundedShadowView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 15
        self.layer.shadowOpacity = 0.75
        self.layer.cornerRadius = self.frame.height / 2
    }
    
}
