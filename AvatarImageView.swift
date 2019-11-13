//
//  AvatarImageView.swift
//  Beeconz
//
//  Created by Umair on 12/02/2019.
//  Copyright © 2019 beeconz. All rights reserved.
//

import UIKit

// MARK: -

@IBDesignable class AvatarImageView: UIImageView {

    // MARK: - Constants and Properties

    fileprivate let initialLabel = UILabel()
    
    var initialText: String = "" {
        
        didSet {
            initialLabel.text = initialText
        }
    }
    
    var initialTextFont: UIFont = UIFont.boldSystemFont(ofSize: 20.0) {
        
        didSet {
            initialLabel.font = initialTextFont
        }
    }
    
    var bgColor: UIColor = UIColor.blue {
        
        didSet {
            backgroundColor = bgColor
        }
    }
    
    var borderColor: UIColor = UIColor.gray {
        
        didSet {
            updateBorderColor()
        }
    }
    
    open override var image: UIImage? {
        
        didSet {
             initialLabel.isHidden = (image != nil)
        }
    }
    
    // MARK: - Init & Override methods
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLabelFrame()
    }
    
    override func prepareForInterfaceBuilder() {
        configureViewLayer()
    }
    
    // MARK: - Private methods
    
    fileprivate func setup() {
        backgroundColor = bgColor
        
        contentMode = .scaleAspectFill
        clipsToBounds = true
        
        initialLabel.font = initialTextFont
        initialLabel.textColor = UIColor.black
        initialLabel.text = initialText
        initialLabel.textAlignment = .center
        
        addSubview(self.initialLabel)
        
        updateLabelFrame()
        configureViewLayer()
    }
    
    fileprivate func configureViewLayer() {
        layer.cornerRadius = bounds.size.width / 2.0
        layer.borderWidth = 1.0
        updateBorderColor()
    }
    
    fileprivate func updateBorderColor() {
        layer.borderColor = borderColor.cgColor
    }
    
    fileprivate func updateLabelFrame() {
        initialLabel.frame = bounds
        initialLabel.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
    }
}
