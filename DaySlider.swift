//
//  DaySlider.swift
//  GrindFitness
//
//  Created by Umair on 06/12/2018.
//  Copyright © 2018 Citrusbits. All rights reserved.
//

import UIKit

// MARK: -

@IBDesignable class DaySlider: UISlider {

    // MARK: - Constants and Properties
    
    fileprivate let steps = 6
    fileprivate let trackHeight: CGFloat = 5.0
    fileprivate let spacingColor = UIColor.white
    fileprivate let spacingWidth: CGFloat = 2.0
    fileprivate let minTrackColor = UIColor.orange
    fileprivate let maxTrackColor = UIColor.gray
    fileprivate let thumbColor = UIColor.orange

    var valueChanged: ((Int) -> Void)?
    
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
    }
    
    override func prepareForInterfaceBuilder() {
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let innerRect = rect.insetBy(dx: 1.0, dy: 10.0)
        var selectedStepImage: UIImage?
        var unselectedStepImage: UIImage?
        
        UIGraphicsBeginImageContextWithOptions(innerRect.size, false, 0)
        
        if let context = UIGraphicsGetCurrentContext() {
            context.setLineCap(CGLineCap.round)
            context.setLineWidth(trackHeight)
            context.move(to: CGPoint(x: 5.0, y: innerRect.height / 2.0))
            context.addLine(to: CGPoint(x: innerRect.width - 10.0, y: innerRect.height / 2.0))
            context.setStrokeColor(minTrackColor.cgColor)
            context.strokePath()
            
            let minTrackImage = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: .zero)

            context.setLineCap(CGLineCap.round)
            context.setLineWidth(trackHeight)
            context.move(to: CGPoint(x: 5.0, y: innerRect.height / 2.0))
            context.addLine(to: CGPoint(x: innerRect.width - 10.0, y: innerRect.height / 2.0))
            context.setStrokeColor(maxTrackColor.cgColor)
            context.strokePath()
            
            let maxTrackImage = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: .zero)
            
            minTrackImage?.draw(at: CGPoint(x: 0.0, y: 0.0))
            
            let totalSpacingWidth = CGFloat(steps - 1) * spacingWidth
            let stepWidth = (innerRect.width - totalSpacingWidth) / CGFloat(steps)
            
            for i in 1...(steps - 1) {
                let xValue = CGFloat(i) * stepWidth
                
                context.setLineWidth(spacingWidth)
                context.move(to: CGPoint(x: xValue, y: innerRect.height / 2.0 - 5.0))
                context.addLine(to: CGPoint(x: xValue, y: innerRect.height / 2.0 + 5.0))
                context.setStrokeColor(spacingColor.cgColor)
                context.strokePath()
            }
            
            selectedStepImage = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: .zero)
            
            maxTrackImage?.draw(at: CGPoint(x: 0.0, y: 0.0))
            
            for i in 1...(steps - 1) {
                let xValue = CGFloat(i) * stepWidth
                
                context.setLineWidth(spacingWidth)
                context.move(to: CGPoint(x: xValue, y: innerRect.height / 2.0 - 5.0))
                context.addLine(to: CGPoint(x: xValue, y: innerRect.height / 2.0 + 5.0))
                context.setStrokeColor(spacingColor.cgColor)
                context.strokePath()
            }
            
            unselectedStepImage = UIGraphicsGetImageFromCurrentImageContext()?.resizableImage(withCapInsets: .zero)
        }

        UIGraphicsEndImageContext();
        
        setMinimumTrackImage(selectedStepImage, for: .normal)
        setMaximumTrackImage(unselectedStepImage, for: .normal)

        let thumbImage = UIImage.createCircle(color: thumbColor, diameter: 24.0)
        setThumbImage(thumbImage, for: .normal)
        setThumbImage(thumbImage, for: .selected)
        setThumbImage(thumbImage, for: .highlighted)
        setThumbImage(thumbImage, for: .focused)
    }
    
    // MARK: - Private methods
    
    fileprivate func setup() {
        minimumValue = 1
        maximumValue = 7
        isContinuous = false
        
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.black.cgColor
        
        addTarget(self, action: #selector(valueDidChange(sender:)), for: .valueChanged)
    }

    @objc func valueDidChange(sender: UISlider) {
        print("Slider value changed")

        let roundedStepValue = roundf(sender.value)
        sender.setValue(roundedStepValue, animated: true)
        
        print("Slider step value \(Int(roundedStepValue))")
        
        if valueChanged != nil {
            valueChanged!(Int(roundedStepValue))
        }
        
//        sendActions(for: .valueChanged)
    }
}

// MARK: - Image helper methods

extension UIImage {
    
    static func createCircle(color: UIColor, diameter: CGFloat) -> UIImage {
        let aRect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        
        UIGraphicsBeginImageContextWithOptions(aRect.size, false, 0)
        
        color.setFill()
        
        let path = UIBezierPath(ovalIn: aRect)
        path.fill()
        
        let anImg = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return anImg
    }
}
