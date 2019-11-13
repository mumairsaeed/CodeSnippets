//
//  CircularPickerView.swift
//  FullyRaw
//
//  Created by Umair Saeed on 27/08/2017.
//  Copyright © 2017 Umair. All rights reserved.
//


import UIKit

// MARK: - Delegate

protocol CircularPickerViewDelegate: class {
    func circularPickerView(circularPickerView: CircularPickerView, didSelectIndexAt index: Int)
}

// MARK: - Cell

private class CircularPickerViewItem: UIView {
    
    var marked: Bool = false {
        
        didSet {
            textLabel.textColor = (marked == true) ? .white : .lightGray
        }
    }
    
    // MARK: -
    
    var textLabel: UILabel!
    
    // MARK: -
    
    init() {
        super.init(frame: CGRect.zero)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init!(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: -
    
    func setup() {
        textLabel = UILabel(frame: self.bounds)
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 1
        textLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
        textLabel.textColor = UIColor(white: 1.0, alpha: 0.5)
        
        self.addSubview(textLabel)
        // Add constraints
//        self.addFourPinContraintsToSubview(subV: textLabel, topMargin: 0, leadingMargin: 0, trailingMargin: 0, bottomMargin: 0)
    }
}

// MARK: - View

private let itemsVisible = 3

class CircularPickerView: UIView {

    // MARK: -
    // MARK: Constants and Properties
    
    fileprivate let indicatorWidth: CGFloat = 18
    fileprivate let indicatorHeight: CGFloat = 10
    fileprivate let cellWidth: CGFloat = UIScreen.main.bounds.size.width / CGFloat(itemsVisible)
    
    fileprivate var currentVelocityX: CGFloat?
    fileprivate var maxVelocity: CGFloat = 100.0
    fileprivate var originalChoicesNumber = 0
    fileprivate var itemViews: [CircularPickerViewItem] = []

    fileprivate var scrollView = UIScrollView()
    fileprivate var currentSelectedIndex: Int?
    fileprivate var currentRealSelectedIndex: Int?
    fileprivate var didSetDefaultIndex: Bool = false
    
    weak var delegate: CircularPickerViewDelegate?
    
    var selectedIndex: Int? {
        let view = viewAtLocation(CGPoint(x: scrollView.contentOffset.x + scrollView.frame.width / 2.0, y: scrollView.frame.minY))
        
        guard var index = itemViews.index(where: { $0 == view }) else {
            return nil
        }
        
        while index >= originalChoicesNumber {
            index -= originalChoicesNumber
        }
        
        return index
    }

    fileprivate var realSelectedIndex: Int? {
        let view = viewAtLocation(CGPoint(x: scrollView.contentOffset.x + scrollView.frame.width / 2.0, y: scrollView.frame.minY))
        
        guard let index = itemViews.index(where: { $0 == view }) else {
            return nil
        }
        
        return index
    }
    
    var items = [String]() {
        
        didSet {
            originalChoicesNumber = items.count
            
            currentSelectedIndex = nil
            currentRealSelectedIndex = nil
            
            itemViews = [CircularPickerViewItem]()
            var views = [CircularPickerViewItem]()
            
            for itemString in items {
                let itemView = CircularPickerViewItem(frame: CGRect(x: 0, y: 0, width: cellWidth, height: self.bounds.size.height))
                itemView.marked = false
                itemView.textLabel.text = itemString
                
                views.append(itemView)
            }
            
            (0..<3).forEach { counter in
                
                var newViews: [CircularPickerViewItem] = views.map { aView in
                    
                    if counter == 1 {
                        return aView
                        
                    } else {
                        
                        do {
                            return try aView.copyView() as! CircularPickerViewItem
                            
                        } catch {
                            fatalError("There was a problem with copying view.")
                        }
                    }
                }
                
                // In copy its maing the title nil
                for index in 0..<newViews.count {
                    let itemView = newViews[index]
                    
                    if index < items.count && itemView.textLabel.text == nil {
                        itemView.textLabel.text = items[index]
                        newViews[index] = itemView
                    }
                }
                
                itemViews.append(contentsOf: newViews)
            }
            
            setupViews(itemViews)
        }
    }
    
    // MARK: -
    // MARK: Init, deinit & override methods
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    deinit {
        scrollView.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        guard (scrollView.frame.width > 0 && scrollView.frame.height > 0)  else { return }
        
        let width: CGFloat = itemViews.reduce(0.0) { $0 + $1.frame.width }

        scrollView.contentSize = CGSize(width: width, height: frame.height)
        maxVelocity = scrollView.contentSize.width / 6.0

        guard currentSelectedIndex == nil || didSetDefaultIndex == false else { return }
  
        if didSetDefaultIndex == false {
            selectItem(0, animated: false)
            didSetDefaultIndex = true
            
        } else {
            selectItem(0, animated: false)
        }
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let _ = change?[NSKeyValueChangeKey.newKey], keyPath == "contentOffset" {

            guard (scrollView.frame.width > 0 && scrollView.frame.height > 0)  else { return }
            
            let newOffset = scrollView.contentOffset
            let segmentWidth = scrollView.contentSize.width / CGFloat(itemsVisible)
            var newOffsetX: CGFloat!
            
            if (newOffset.x >= segmentWidth * 2.0) { // in the 3rd part
                newOffsetX = newOffset.x - segmentWidth // move back one segment
                
            } else if (newOffset.x + scrollView.bounds.width) <= segmentWidth { // First part
                newOffsetX = newOffset.x + segmentWidth // move forward one segment
            }
            
            // We are in middle segment still so no need to scroll elsewhere
            guard newOffsetX != nil && newOffsetX > 0 else {
                return
            }
            
            self.scrollView.contentOffset.x = newOffsetX
        }
    }
    
    override func draw(_ rect: CGRect) {
        let startPoint = CGPoint(x: (rect.midX - (indicatorWidth / 2)), y: (rect.height - 0))
        let middlePoint = CGPoint(x: rect.midX, y: (rect.height - 0) + indicatorHeight)
        let endPoint = CGPoint(x: (startPoint.x + indicatorWidth), y: (rect.height - 0))
        
        let indicatorPath = UIBezierPath()
        
        indicatorPath.move(to: startPoint)
        indicatorPath.addLine(to: middlePoint)
        indicatorPath.addLine(to: endPoint)
        
        indicatorPath.close()
        
        let indicatorLayer = CAShapeLayer()
        indicatorLayer.path = indicatorPath.cgPath
        indicatorLayer.fillColor = UIColor.white.cgColor
        indicatorLayer.name = "indicatorLayer"
        
        self.layer.addSublayer(indicatorLayer)
        
        super.draw(rect)
    }
    
    // MARK: -
    // MARK: Public methods
    
    func selectItemWithForce(_ choice: Int) {
        selectItem(choice, animated: false, force: true)
    }
    
    func selectItem(_ choice: Int, animated: Bool) {
        selectItem(choice, animated: animated, force: false)
    }
    
    func movePicker(forward: Bool) {
        
        if items.count > 0 {
            // As we have three items
            let cellHalf = cellWidth / 2.0
            let xPosition =  (forward == true) ?  ((cellWidth * 2.0) + cellHalf) : cellHalf
            let point = CGPoint(x: scrollView.contentOffset.x + xPosition, y: scrollView.frame.minY)
            
            if let view = viewAtLocation(point), let index = itemViews.index(of: view as! CircularPickerViewItem) {
                selectItem(index, animated: true, force: true)
            }
        }
    }
    
    // MARK: -
    // MARK: User action methods
    
    @objc func viewTapped(_ gestureRecognizer: UIGestureRecognizer) {
        let touchPoint = gestureRecognizer.location(in: scrollView)

        if let view = viewAtLocation(touchPoint), let index = itemViews.index(of: view as! CircularPickerViewItem) {
            selectItem(index, animated: true, force: true)
        }
    }
    
    // MARK: -
    // MARK: Private methods
    
    fileprivate func setup() {
        self.backgroundColor = UIColor.white
        
        scrollView = UIScrollView(frame: self.bounds)
        scrollView.backgroundColor = UIColor.white
        scrollView.delegate = self
        scrollView.isScrollEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        self.addSubview(scrollView)
//        self.addFourPinContraintsToSubview(subV: scrollView, topMargin: 0, leadingMargin: 0, trailingMargin: 0, bottomMargin: 0)
        
        scrollView.addObserver(self, forKeyPath: "contentOffset", options: [.new, .old], context: nil)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self
        scrollView.addGestureRecognizer(gestureRecognizer)
    }
    
    fileprivate func setupViews(_ views: [UIView]) {
        var x: CGFloat = 0.0
        
        views.forEach { view in
            view.frame.origin.x = x
            x += view.frame.width
        }
        
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        views.forEach { scrollView.addSubview($0) }
        layoutIfNeeded()
    }
    
    fileprivate func didSelectItem(notify: Bool = true) {
        
        guard let selectedIndex = self.selectedIndex, let realSelectedIndex = self.realSelectedIndex else {
            return
        }
        
        didDeselectItem()
        
        (0..<3).forEach { counter in
            let indexToMark = selectedIndex + (counter * originalChoicesNumber)
            let view = itemViews[indexToMark]
            view.marked = true
        }
        
        if notify {
            delegate?.circularPickerView(circularPickerView: self, didSelectIndexAt: selectedIndex)
        }
        
        currentSelectedIndex = selectedIndex
        currentRealSelectedIndex = realSelectedIndex
        currentVelocityX = nil
        scrollView.isScrollEnabled = true
    }
    
    fileprivate func didDeselectItem() {
        guard let currentRealSelectedIndex = self.currentRealSelectedIndex, let currentSelectedIndex = self.currentSelectedIndex else {
            return
        }
        
        (0..<3).forEach { counter in
            let indexToMark = currentSelectedIndex + (counter * originalChoicesNumber)
            let view = itemViews[indexToMark]
            view.marked = false
        }
    }
    
    fileprivate func viewAtLocation(_ touchLocation: CGPoint) -> UIView? {
        
        for subview in scrollView.subviews where subview.frame.contains(touchLocation) {
            return subview
        }
        
        return nil
    }
    
    fileprivate func nearestViewAtLocation(_ touchLocation: CGPoint) -> UIView {
        var view: UIView!
        
        if let newView = viewAtLocation(touchLocation) {
            view = newView
            
        } else {
            // Now check left and right margins to nearest views
            let step: CGFloat = 1.0
            var targetX = touchLocation.x
            
            // Left
            var leftView: UIView?
            
            repeat {
                targetX -= step
                leftView = viewAtLocation(CGPoint(x: targetX, y: touchLocation.y))
                
            } while (leftView == nil)
            
            let leftMargin = touchLocation.x - leftView!.frame.maxX
            
            // Right
            var rightView: UIView?
            
            repeat {
                targetX += step
                rightView = viewAtLocation(CGPoint(x: targetX, y: touchLocation.y))
                
            } while (rightView == nil)
            
            let rightMargin = rightView!.frame.minX - touchLocation.x
            
            if rightMargin < leftMargin {
                view = rightView!
                
            } else {
                view = leftView!
            }
        }
        
        return view
    }
    
    fileprivate func selectItem(_ choice: Int, animated: Bool, force: Bool) {
        var index = choice
        if !force {
            // allow scroll only in the range of original items
            guard choice < itemViews.count / 3 else {
                return
            }
            // move to same item in middle segment
            index = index + originalChoicesNumber
        }
        
        let choiceView = itemViews[index]
        let x = choiceView.center.x - scrollView.frame.width / 2.0
        
        let newPosition = CGPoint(x: x, y: scrollView.contentOffset.y)
        let animationIsNotNeeded = newPosition.equalTo(scrollView.contentOffset)
        scrollView.setContentOffset(newPosition, animated: animated)
        
        if !animated || animationIsNotNeeded {
            didSelectItem(notify: false)
        }
    }
}

extension CircularPickerView: UIGestureRecognizerDelegate, UIScrollViewDelegate {
    
    func gestureRecognizer(_: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating")
        didSelectItem()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        print("scrollViewDidEndScrollingAnimation")
        didSelectItem()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        print("velocity: \(velocity)")

        let originalVelocityX = velocity.x
        var velocity = velocity.x * 300.0
        
        if originalVelocityX > 2.2 || originalVelocityX < -2.2 {
            velocity = originalVelocityX * 200.0
        }
        
        var targetX = scrollView.frame.width / 2.0 + velocity
        
        // When the target is being scrolled and we scroll again,
        // the position we need to take as base should be the destination
        // because velocity will stay and if we will take the current position
        // we won't get correct item because the X distance we skipped in the
        // last circle wasn't included in the calculations.
        if let oldTargetX = currentVelocityX {
            targetX += (oldTargetX - scrollView.contentOffset.x)
            
            // To snap incase stopped in between
            if velocity == 0 {
                targetX = scrollView.contentOffset.x
            }
            
        } else {
            targetX += scrollView.contentOffset.x
        }
        
        if velocity >= maxVelocity {
            velocity = maxVelocity
            
        } else if velocity <= -maxVelocity {
            velocity = -maxVelocity
        }
        
        if (targetX > scrollView.contentSize.width || targetX < 0.0) {
            targetX = scrollView.contentSize.width / CGFloat(itemsVisible) + velocity
        }
        
        let choiceView = nearestViewAtLocation(CGPoint(x: targetX, y: scrollView.frame.minY))
        let newTargetX = choiceView.center.x - scrollView.frame.width / 2.0
        currentVelocityX = newTargetX
        targetContentOffset.pointee.x = newTargetX
    }
}

enum ArchiveCopyingError: Error {
    case view
}

// MARK: - UIView helper method
extension UIView {
    
    fileprivate func prepareConstraintsForArchiving() {
        constraints.forEach { $0.shouldBeArchived = true }
        subviews.forEach { $0.prepareConstraintsForArchiving() }
    }
    
    public func copyView() throws -> UIView {
        prepareConstraintsForArchiving()
        guard let view = NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as? UIView else { throw ArchiveCopyingError.view }
        return view
    }
}

// MARK: - How to use

// Create property
//@IBOutlet weak var categoryView: CircularPickerView!

// setup
//categoryView.delegate = self
//categoryView.items = categories
//categoryView.selectItem(0, animated: false)

// Listen delegate
//
//func circularPickerView(circularPickerView: CircularPickerView, didSelectIndexAt index: Int) {
//    // You actions
//}
