//
//  DayNumberView.swift
//  GrindFitness
//
//  Created by Umair on 06/12/2018.
//  Copyright © 2018 Citrusbits. All rights reserved.
//

import UIKit

// MARK: -

@IBDesignable class DayNumberView: UIView {

    // MARK: - Constants and Properties
    
    @IBInspectable var selectedDay = 1  {
        
        didSet {
            
            if selectedDay < 1 {
                selectedDayNumber = 1
                
            } else if selectedDay > 7 {
                selectedDayNumber = 7
                
            } else {
                selectedDayNumber = selectedDay
            }
        }
    }
    
    fileprivate var selectedDayNumber = 1  {
        
        didSet {
            setNeedsDisplay()
        }
    }
    
    fileprivate let textFont = UIFont.boldSystemFont(ofSize: 14.0)
    fileprivate let normalColor = UIColor(red: 155.0 / 255.0, green: 155.0 / 255.0, blue: 155.0 / 255.0, alpha: 1.0)
    fileprivate let selectedColor = UIColor.black

    // MARK: - Init & Override methods
    
    override func draw(_ rect: CGRect) {
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.black.cgColor
        
        var textItems = [NSString]()
        var textWidths = [CGFloat]()
        var selectedIndex = 0
        
        for i in 1...7 {
            let textColor = (i == selectedDayNumber) ? selectedColor : normalColor
            let attributes = [NSAttributedString.Key.font: textFont, NSAttributedString.Key.foregroundColor: textColor] as [NSAttributedString.Key: Any]
            
            let textToDraw = NSString(string: "\(i)")
            textItems.append(textToDraw)
            
            let size = textToDraw.size(withAttributes: attributes)
            textWidths.append(size.width)
            
            if i == selectedDayNumber {
                selectedIndex = i - 1
            }
        }
        
        let widthSum = textWidths.reduce(0, +)
        let spacing = (rect.width - widthSum) / 6
        var xValue = CGFloat(0.0)
        
        for i in 0..<textItems.count {
            let textColor = (i == selectedIndex) ? selectedColor : normalColor
            let attributes = [NSAttributedString.Key.font: textFont, NSAttributedString.Key.foregroundColor: textColor] as [NSAttributedString.Key: Any]
            
            let textToDraw = textItems[i]
            textToDraw.draw(at: CGPoint(x: xValue, y: 0.0), withAttributes: attributes)
            
            xValue = xValue + spacing + textWidths[i]
        }
    }
}
