//
//  CBSegmentedControl.swift
//  Produce Section Challenge
//
//  Created by Umair Saeed on 08/05/2019.
//  Copyright © 2019 Umair. All rights reserved.
//

import UIKit

// MARK: -

class CBSegmentedControl: UIControl {
    
    // MARK: - Constants and Properties
    
    fileprivate var segmentButtons: [UIButton]?
    fileprivate var segmentItems: [String] = ["A", "B"]
    fileprivate var lineView: UIView!
    fileprivate var indicatorView: UIView!
    
    fileprivate let indicatorThickness: CGFloat = 3
    fileprivate var indicatorXConstraint: NSLayoutConstraint!
    
    fileprivate var xToItem: UIView {
        return segmentButtons![selectedSegmentIndex]
    }
    
    fileprivate var widthToItem: UIView {
        return segmentButtons![selectedSegmentIndex]
    }
    
    fileprivate var itemWidth: CGFloat {
        return self.bounds.size.width / CGFloat(numberOfSegments)
    }
    
    var selectedSegmentIndex: Int = 0 {
        
        didSet {
            configureIndicator()
            
            if let buttons = segmentButtons {
                
                for button in buttons {
                    button.isSelected = false
                }
                
                let selectedButton = buttons[selectedSegmentIndex]
                selectedButton.isSelected = true
            }
        }
    }
    
    var numberOfSegments: Int {
        return segmentItems.count
    }
    
    // MARK: - Init and override methods
    
    public init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    public init(items: [String]) {
        super.init(frame: CGRect.zero)
        segmentItems = items
        setup()
    }
    
    override func prepareForInterfaceBuilder() {
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        configureIndicator()
    }
    
    // MARK: - Init helper methods
    
    fileprivate func setup() {
        self.backgroundColor = UIColor.white
        setupButtons()
        setupLine()
        setupIndicator()
        
        selectedSegmentIndex = 0
    }
    
    fileprivate func setupButtons() {
        guard numberOfSegments > 0 else { return }
        
        var views = [String: AnyObject]()
        var xVisualFormat = "H:|"
        let yVisualFormat = "V:|[button0]|"
        var previousButtonName: String? = nil
        
        var buttons = [UIButton]()
        
        defer {
            segmentButtons = buttons
        }
        
        for index in 0..<numberOfSegments {
            let button = UIButton(type: .custom)
            configureButton(button)
            
            button.translatesAutoresizingMaskIntoConstraints = false
            
            button.setTitle(titleForSegmentAtIndex(index), for: .normal)
            button.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
            
            buttons.append(button)
            
            self.addSubview(button)
            
            let buttonName = "button\(index)"
            views[buttonName] = button
            
            if let previousButtonName = previousButtonName {
                xVisualFormat.append("[\(buttonName)(==\(previousButtonName))]")
                
            } else {
                xVisualFormat.append("[\(buttonName)]")
            }
            
            previousButtonName = buttonName
        }
        
        xVisualFormat.append("|")
        
        let xConstraints = NSLayoutConstraint.constraints(withVisualFormat: xVisualFormat, options: [.alignAllTop, .alignAllBottom], metrics: nil, views: views)
        let yConstraints = NSLayoutConstraint.constraints(withVisualFormat: yVisualFormat, options: [], metrics: nil, views: views)
        
        NSLayoutConstraint.activate(xConstraints)
        NSLayoutConstraint.activate(yConstraints)
    }
    
    fileprivate func setupLine() {
        lineView = UIView()
        lineView.backgroundColor = UIColor.gray
        
        self.addSubview(lineView)
        
        lineView.translatesAutoresizingMaskIntoConstraints = false
        
        let trailingConstraint = NSLayoutConstraint (item: lineView!,
                                                     attribute: .trailing,
                                                     relatedBy: .equal,
                                                     toItem: self,
                                                     attribute: .trailing,
                                                     multiplier: 1,
                                                     constant: 0)
        
        let leadingConstraint = NSLayoutConstraint (item: lineView!,
                                                    attribute: .leading,
                                                    relatedBy: .equal,
                                                    toItem: self,
                                                    attribute: .leading,
                                                    multiplier: 1,
                                                    constant: 0)
        
        let bottomConstraint = NSLayoutConstraint (item: lineView!,
                                                   attribute: .bottom,
                                                   relatedBy: .equal,
                                                   toItem: self,
                                                   attribute: .bottom,
                                                   multiplier: 1,
                                                   constant: 0)
        
        let heightConstraint = NSLayoutConstraint(item: lineView!,
                                                  attribute: .height,
                                                  relatedBy: .equal,
                                                  toItem: nil,
                                                  attribute: .notAnAttribute,
                                                  multiplier: 1,
                                                  constant: indicatorThickness)
        
        self.addConstraints([leadingConstraint, trailingConstraint, bottomConstraint, heightConstraint])
    }
    
    fileprivate func setupIndicator() {
        guard numberOfSegments > 0 else { return }
        
        indicatorView = UIView()
        indicatorView.backgroundColor = UIColor.blue
        
        self.addSubview(indicatorView)
        
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        let xConstraint = NSLayoutConstraint(item: indicatorView!,
                                             attribute: .centerX,
                                             relatedBy: .equal,
                                             toItem: xToItem,
                                             attribute: .centerX,
                                             multiplier: 1,
                                             constant: 0)
        
        indicatorXConstraint = xConstraint
        
        let bottomConstraint = NSLayoutConstraint(item: indicatorView!,
                                                  attribute: .bottom,
                                                  relatedBy: .equal,
                                                  toItem: self,
                                                  attribute: .bottom,
                                                  multiplier: 1,
                                                  constant: 0)
        
        let widthConstraint = NSLayoutConstraint(item: indicatorView!,
                                                 attribute: .width,
                                                 relatedBy: .equal,
                                                 toItem: widthToItem,
                                                 attribute: .width,
                                                 multiplier: 1,
                                                 constant: 0)
        
        let heightConstraint = NSLayoutConstraint(item: indicatorView!,
                                                  attribute: .height,
                                                  relatedBy: .equal,
                                                  toItem: nil,
                                                  attribute: .notAnAttribute,
                                                  multiplier: 1,
                                                  constant: indicatorThickness)
        
        self.addConstraints([xConstraint, bottomConstraint, widthConstraint, heightConstraint])
    }
    
    // MARK: - Configure methods
    
    fileprivate func configureView() {
        configureIndicator()
        configureButtons()
    }
    
    fileprivate func configureIndicator() {
        indicatorXConstraint.constant =  CGFloat(selectedSegmentIndex) * itemWidth
    }
    
    fileprivate func configureButtons() {
        
        guard let buttons = segmentButtons else {
            return
        }
        
        for button in buttons {
            configureButton(button)
        }
    }
    
    fileprivate func configureButton(_ button: UIButton) {
        button.backgroundColor = UIColor.white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14.0)
        button.setTitleColor(UIColor.black, for: .selected)
        button.setTitleColor(UIColor.black, for: UIControl.State())
    }
    
    // MARK: - Action methods
    
    @objc func didTapButton(_ button: UIButton) {
        guard let index = segmentButtons?.index(of: button) else {
            return
        }
        
        // Same
        if index == selectedSegmentIndex {
            return
        }
        
        setSelectedSegmentIndex(index)
        self.sendActions(for: .valueChanged)
    }
    
    // MARK: - Public methods
    
    func setTitle(_ title: String, forSegmentAt index: Int) {
        guard let buttons = segmentButtons, index < segmentItems.count else {
            return
        }
        
        segmentItems[index] = title
        
        let button = buttons[index]
        button.setTitle(title, for: .normal)
    }
    
    func titleForSegmentAtIndex(_ segment: Int) -> String? {
        guard segment < segmentItems.count else {
            return nil
        }
        
        return segmentItems[segment]
    }
    
    func setSelectedSegmentIndex(_ index: Int, animated: Bool = true) {
        selectedSegmentIndex = index
        
        if animated {
            
            UIView.animate(withDuration: 0.4, animations: {
                self.layoutIfNeeded()
            })
        }
    }
}

// MARK: - How to use
// Create a segmented Control
//let segmentedControl = CBSegmentedControl(items: ["One", "Two"])

// Add to view
// segmentedControl.addTarget(nil, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
// segmentedControl.selectedSegmentIndex = 0

// Action method
//@objc func segmentedControlValueChanged(_ sender: Any) {
//    segmentedControl.selectedSegmentIndex // Get selected segment
//}
