//
//  HorizontalPickerView.swift
//  FullyRaw
//
//  Created by Umair Saeed on 27/08/2017.
//  Copyright © 2017 Umair. All rights reserved.
//

import UIKit

// MARK: - Delegate

protocol HorizontalPickerViewDelegate: class {
    func pickerView(pickerView: HorizontalPickerView, didSelectIndexAt index: Int)
}

// MARK: - Cell

private class HorizontalPickerViewCell: UICollectionViewCell {
    
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
        textLabel = UILabel(frame: self.contentView.bounds)
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 0
        textLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
        textLabel.textColor = UIColor.lightGray
        textLabel.highlightedTextColor = UIColor.white
        
        self.contentView.addSubview(textLabel)
//        self.contentView.addFourPinContraintsToSubview(subV: textLabel, topMargin: 0, leadingMargin: 0, trailingMargin: 0, bottomMargin: 0)
    }
}

// MARK: - View

class HorizontalPickerView: UIView {
    
    // MARK: - Constants and Properties
    
    fileprivate var collectionView: UICollectionView!
    fileprivate let indicatorWidth: CGFloat = 18
    fileprivate let indicatorHeight: CGFloat = 10
    fileprivate let cellWidth: CGFloat = UIScreen.main.bounds.size.width / 3.0
    
    fileprivate var selectedIndex: Int = 0
    
    weak var delegate: HorizontalPickerViewDelegate?
    
    var items = [String]()
    
    // MARK: - Init, deinit & override methods
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    deinit {
        collectionView.dataSource = nil
        collectionView.delegate = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if items.count > 0 {
            scrollToIndex(index: selectedIndex, animated: false)
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
    
    // MARK: - Public methods
    
    func moveToIndex(index: Int, animated: Bool) {
        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()
        
        if items.count > index {
            selectIndex(index: index, animated: animated, notifySelection: false)
            
        } else if items.count > 0 {
            selectIndex(index: selectedIndex, animated: false, notifySelection: false)
        }
    }
    
    func reset() {
        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()
        
        if items.count > 0 {
            selectIndex(index: 0, animated: true, notifySelection: false)
        }
    }
    
    func reloadData() {
        collectionView.reloadData()
        collectionView.collectionViewLayout.invalidateLayout()
        
        if items.count > 0 {
            selectIndex(index: selectedIndex, animated: false, notifySelection: false)
        }
    }
    
    func movePicker(forward: Bool) {
        
        if items.count > 0 {
            
            let index = (forward == true) ? selectedIndex + 1 : selectedIndex - 1
            
            if (index >= 0) && (index < items.count) {
                selectIndex(index: index, animated: true)
            }
        }
    }
    
    // MARK: - Private methods
    
    fileprivate func setup() {
//        self.layer.masksToBounds = false
        self.backgroundColor = UIColor.white
        
        //Collection View
//        var collectionRect = self.bounds
//        collectionRect.size.height = collectionRect.size.height - indicatorHeight
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false
        collectionView.contentInset = UIEdgeInsets.zero
        
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        
        collectionView.register(HorizontalPickerViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(HorizontalPickerViewCell.self))
        
        self.addSubview(collectionView)
//        self.addFourPinContraintsToSubview(subV: collectionView, topMargin: 0, leadingMargin: 0, trailingMargin: 0, bottomMargin: 0)
    }
    
    fileprivate func scrollToIndex(index: Int, animated: Bool = false) {
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
    }
    
    fileprivate func selectIndex(index: Int, animated: Bool = false) {
        selectIndex(index: index, animated: animated, notifySelection: true)
    }
    
    fileprivate func selectIndex(index: Int, animated: Bool, notifySelection: Bool) {
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.selectItem(at: indexPath, animated: animated, scrollPosition: UICollectionView.ScrollPosition())
        
        scrollToIndex(index: index, animated: animated)
        selectedIndex = index
        
        if notifySelection {
            delegate?.pickerView(pickerView: self, didSelectIndexAt: index)
        }
    }
    
    fileprivate func didEndScrolling() {
        let center = self.convert(collectionView.center, to: collectionView)
        
        if let indexPath = self.collectionView.indexPathForItem(at: center) {
            selectIndex(index: indexPath.item, animated: true, notifySelection: true)
        }
    }
}

// MARK: -

extension HorizontalPickerView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = items.count
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(HorizontalPickerViewCell.self), for: indexPath) as! HorizontalPickerViewCell
        
        cell.textLabel.text = items[indexPath.row]
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectIndex(index: indexPath.item, animated: true)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: cellWidth, bottom: 0.0, right: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // MARK: - UIScrollViewDelegate
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        didEndScrolling()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if !decelerate {
            didEndScrolling()
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        self.collectionView.layer.mask?.frame = self.collectionView.bounds
        CATransaction.commit()
    }
}


// MARK: - How to use

// Create property
//@IBOutlet weak var pickerView: HorizontalPickerView!

// setup
//pickerView.delegate = self
//pickerView.items = dayStrings
//pickerView.moveToIndex(index: 0, animated: false)


// Listen delegate
//func pickerView(pickerView: HorizontalPickerView, didSelectIndexAt index: Int) {
//
//}
