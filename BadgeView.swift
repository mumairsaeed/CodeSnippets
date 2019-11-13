//
//  BadgeView.swift
//  Produce Section Challenge
//
//  Created by Umair Saeed on 08/05/2019.
//  Copyright © 2019 Umair. All rights reserved.
//

import UIKit

// MARK: -

struct BadgeData {
    let name: String
    let color: String // hex string
    
    init(badgeName: String, badgeColor: String) {
        name = badgeName
        color = badgeColor
    }
}

private struct ViewConstants {
    static let BadgeSpacing: CGFloat = 5.0
    static let RowSpacing: CGFloat = 5.0
    static let BadgeHeight: CGFloat = 25.0
    static let TextFont = UIFont.boldSystemFont(ofSize: 12.0)
    static let TextInsets = UIEdgeInsets.init(top: 4.0, left: 20.0, bottom: 5.0, right: 20.0)
    static let TextColor = UIColor.white

    
    // This harder coded value (20: Image leading), (120: Image width), (20: view leading), (20: view trailing)
    static let ViewMargin: CGFloat = 20 + 120 + 20 + 20
    
    static let CommonAttributes: [NSAttributedString.Key: Any] = {
        let attributes = [NSAttributedString.Key.font: TextFont, NSAttributedString.Key.foregroundColor: TextColor]
        return attributes
    }()
}

// MARK: -

typealias BadgeEventHandler = (Int) -> Void

// MARK: -

class BadgeView: UIView {
    
    // MARK: -
    
    fileprivate var badgeData = [BadgeData]()
    fileprivate var texts = [String]()
    fileprivate var badgeSizes = [CGSize]()
    fileprivate var textSizes = [CGSize]()
    
    fileprivate var viewCalculatedHeight: CGFloat = 0
    fileprivate var badgeFrames = [CGRect]()
    
    var badgeAction: BadgeEventHandler?
    
    // MARK: - Init & Override methods
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override var intrinsicContentSize: CGSize {
        let viewInfo = setupLayout()
        viewCalculatedHeight = viewInfo.viewHeight
        badgeFrames = viewInfo.badgeFrames
        return CGSize(width: UIView.noIntrinsicMetric, height: viewCalculatedHeight)
    }
    
    override func draw(_ rect: CGRect) {
        
        if badgeFrames.count < 1 {
            return
        }
        
        let badgeRects = badgeFrames
        let totalItems: Int = badgeRects.count
        
        for index in 0..<totalItems {
            let badgeString = texts[index]
            let badgeRect = badgeRects[index]
            
            let textToDraw = NSString(string: badgeString)
            let stringSize = textSizes[index]
            
            let badgeBGColor = UIColor(hex: ((badgeData[index].color) + "ff"))
            
            let path = UIBezierPath(roundedRect: badgeRect, cornerRadius: (badgeRect.size.height / 2))
            
            badgeBGColor!.setFill()
            path.fill()
            
            let textTop = ceil(badgeRect.origin.y + ((badgeRect.size.height - stringSize.height) / 2.0))
            let textRect = CGRect(x: (badgeRect.origin.x + ViewConstants.TextInsets.left), y: textTop, width: badgeRect.size.width, height: badgeRect.size.height)
            textToDraw.draw(in: textRect, withAttributes: ViewConstants.CommonAttributes)
        }
    }
    
    // MARK: - Public methods
    
    func loadBadges(badges: [BadgeData]) {
        badgeSizes = [CGSize]()
        textSizes = [CGSize]()
        texts = [String]()
        
        badgeData = badges
        
        for badge in badgeData {
            let badgeAndTextSize = getBadgeAndTextSize(forText: badge.name)
            badgeSizes.append(badgeAndTextSize.badgeSize)
            textSizes.append(badgeAndTextSize.textSize)
            texts.append(badge.name)
        }
    }
    
    // MARK: - Private methods
    
    fileprivate func getBadgeAndTextSize(forText text: String) -> (badgeSize: CGSize, textSize: CGSize) {
        var stringSize =  text.stringSize(constrainedToWidth: Double(textMaxWidth()), font: ViewConstants.TextFont)
        let stringWidth = ceil(stringSize.width)
        let stringHeight = ceil(stringSize.height)
        
        stringSize = CGSize(width: stringWidth, height: stringHeight)
        
        let tagHeight = ceil(ViewConstants.TextInsets.top + stringSize.height + ViewConstants.TextInsets.bottom)
        let tagwidth = ceil(ViewConstants.TextInsets.left + stringSize.width + ViewConstants.TextInsets.right)
        
        let tagSize = CGSize(width: tagwidth, height: tagHeight)
        
        return (tagSize, stringSize)
    }
    
    fileprivate func textMaxWidth() -> CGFloat {
        let textMargin: CGFloat = ViewConstants.TextInsets.left + ViewConstants.TextInsets.right
        let totalMargin = ViewConstants.ViewMargin + textMargin
        
        return UIScreen.main.bounds.width - totalMargin
    }
    
    fileprivate func setupLayout() -> (viewHeight: CGFloat, badgeFrames: [CGRect]) {
        var allRects = [CGRect]()
        var xValue: CGFloat = 0.0
        var yValue: CGFloat = 0.0
        
        let totalItems: Int = badgeSizes.count
        
        for index in 0..<totalItems {
            let tagSize = badgeSizes[index]
            
            if (xValue + tagSize.width) > (UIScreen.main.bounds.width - ViewConstants.ViewMargin) {
                xValue = 0
                yValue += (ViewConstants.BadgeHeight + ViewConstants.RowSpacing)
            }
            
            let aRect = CGRect(x: xValue, y: yValue, width: tagSize.width, height: tagSize.height)
            allRects.append(aRect)
            
            xValue += (tagSize.width + ViewConstants.BadgeSpacing)
            
            let badgeButton = UIButton()
            badgeButton.frame = aRect
            badgeButton.tag = index
            badgeButton.addTarget(self, action: #selector(badgeButtonTapped(sender:)), for: .touchUpInside)
            
            addSubview(badgeButton)
        }
        
        if (allRects.count > 0) {
            let lastRect = allRects.last
            yValue += (lastRect?.size.height)!
        }
        
        return (yValue, allRects)
    }
    
    @objc func badgeButtonTapped (sender: UIButton) {
        badgeAction?(sender.tag)
    }
}

// MARK: - String helper methods

extension String {
    
    func stringSize(constrainedToWidth width: Double, font: UIFont) -> CGSize {
        return self.boundingRect(with: CGSize(width: width, height: Double.greatestFiniteMagnitude),
                                 options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                 attributes: [NSAttributedString.Key.font: font],
                                 context: nil).size
    }
}

// MARK: - UIColor helper methods

extension UIColor {
    
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat
        
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
}


// MARK: - How to use
// Add badgeview by interface or code
// Then load badges and listen the badge tap

//    badgeView.loadBadges(badges: allBadges)
//    badgeView.invalidateIntrinsicContentSize()
//    badgeView.setNeedsDisplay()
//
//    badgeView.badgeAction = { [weak self] badgeIndex in
//        // Do your task
//    }

