//
//  GradientView.swift
//  Produce Section Challenge
//
//  Created by Umair Saeed on 08/05/2019.
//  Copyright © 2019 Umair. All rights reserved.
//

import UIKit
// To add gradients on bottom on views

// MARK: -

@IBDesignable
class GradientView: UIView {

    // MARK: -
    
    private let gradientLayer: CAGradientLayer = CAGradientLayer()
    
    @IBInspectable var applyRadius: Bool = false {
        
        didSet {
            layer.cornerRadius = applyRadius ? 6.0 : 0.0
            clipsToBounds = true
        }
    }
    
    // MARK: -
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    // MARK: -
    
    fileprivate func setup() {
        backgroundColor = UIColor.clear
        
        gradientLayer.frame = bounds
        gradientLayer.colors = [UIColor.black.withAlphaComponent(0.9).cgColor, UIColor.black.withAlphaComponent(0).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        
        layer.addSublayer(gradientLayer)
        applyRadius = false
    }
}
