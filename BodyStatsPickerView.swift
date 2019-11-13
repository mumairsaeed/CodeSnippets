//
//  BodyStatsPickerView.swift
//  GrindFitness
//
//  Created by Umair on 04/12/2018.
//  Copyright © 2018 Citrusbits. All rights reserved.
//

import UIKit

// MARK: -

enum BodyStatsPickerViewType: Int {
    case measuringunit = 0
    case weight
    case height
}

enum MeasuringUnit: String {
    case us
    case metric
    
    static let allValues = [us, metric]
    
    func displayString() -> String {
        
        switch self {
            
        case .us:
            return "US"
            
        case .metric:
            return "Metric"
        }
    }
}

//US: Height feet inches : Weight pounds
//Metric: Height cm : Weight Kg

// MARK: -

class BodyStatsPickerView: UIPickerView {

    // MARK: - Constants and Properties
    
    var pickerType = BodyStatsPickerViewType.measuringunit {
        
        didSet {
            reloadAllComponents()
        }
    }
    
    var seletedUnit = MeasuringUnit.us {
        
        didSet {
            reloadAllComponents()
        }
    }
    
    var valueChanged: ((Any) -> Void)?
    
    // MARK: - Init & Override methods
    
    init() {
        super.init(frame: CGRect.zero)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(with type: BodyStatsPickerViewType) {
        self.init()
        
        pickerType = type
    }

    // MARK: - Private methods
    
    fileprivate func setup() {
        self.delegate = self
        self.dataSource = self
        
        backgroundColor = .white
    }
    
    fileprivate func componentCount() -> Int {
        
        switch pickerType {
        case .measuringunit:
            return 1
        case .weight:
            return 2
        case .height:
            return (seletedUnit == .us) ? 4 : 2
        }
    }
    
    fileprivate func rowCountInComponent(component: Int) -> Int {
        var rows = 0
        
        switch pickerType {
        case .measuringunit:
            rows = MeasuringUnit.allValues.count
            break
        case .weight:
            
            switch component {
            case 0:
                rows = (seletedUnit == .us) ? 440 : 200
                break
            case 1:
                rows = 1
                break
            default:
                break
            }
            
            break
        case .height:
            
            if seletedUnit == .us {
                
                switch component {
                case 0:
                    rows = 10
                    break
                case 1:
                    rows = 1
                    break
                case 2:
                    rows = 12
                    break
                case 3:
                    rows = 1
                    break
                default:
                    break
                }
                
            } else {
                switch component {
                case 0:
                    rows = 330
                    break
                case 1:
                    rows = 1
                    break
                default:
                    break
                }
            }
            
            break
        }
        
        return rows
    }
    
    fileprivate func titleString(row: Int, component: Int) -> String {
        var text = ""
        
        switch pickerType {
        case .measuringunit:
            text = titleForUnitRow(row: row, component: component)
            break
        case .weight:
            text = titleForWeightRow(row: row, component: component)
            break
        case .height:
            text = titleForHeightRow(row: row, component: component)
            break
        }
        
        return text
    }
    
    fileprivate func titleForUnitRow(row: Int, component: Int) -> String {
        return MeasuringUnit.allValues[row].displayString()
    }
    
    fileprivate func titleForWeightRow(row: Int, component: Int) -> String {
        var text = ""
        
        switch component {
        case 0:
            text = "\(row + 1)"
            break
        case 1:
            text = (seletedUnit == .us) ? "lbs" : "kg"
            break
        default:
            break
        }
        
        return text
    }
    
    fileprivate func titleForHeightRow(row: Int, component: Int) -> String {
        var text = ""
        
        if seletedUnit == .us {
            
            switch component {
            case 0:
                text = "\(row + 1)"
                break
            case 1:
                text = "ft"
                break
            case 2:
                text = "\(row)"
                break
            case 3:
                text = "in"
                break
            default:
                break
            }
            
        } else {
            switch component {
            case 0:
                text = "\(row + 1)"
                break
            case 1:
                text = "cm"
                break
            default:
                break
            }
        }
        
        return text
    }
    
    fileprivate func attributedTitleString(row: Int, component: Int) -> NSAttributedString {
        let rowTitle = titleString(row: row, component: component)
        
        let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17.0),
                          NSAttributedString.Key.foregroundColor: UIColor.black,
                          NSAttributedString.Key.kern: 0.62] as [NSAttributedString.Key : Any]
        
        let attributedTitle = NSAttributedString(string: rowTitle, attributes: attributes)
        
        return attributedTitle
    }
    
    fileprivate func columnWidth(component: Int) -> CGFloat {
        var width = CGFloat(60.0)
        
        switch pickerType {
        case .measuringunit:
            width = 200
            break
        case .weight:
            
            switch component {
            case 0:
                width = 120
                break
            case 1:
                width = 80
                break
            default:
                break
            }
            
            break
        case .height:
            
            if seletedUnit == .us {
                
                switch component {
                case 0:
                    width = 40
                    break
                case 1:
                    width = 50
                    break
                case 2:
                    width = 40
                    break
                case 3:
                    width = 50
                    break
                default:
                    break
                }
                
            } else {
                switch component {
                case 0:
                    width = 110
                    break
                case 1:
                    width = 80
                    break
                default:
                    break
                }
            }
            
            break
        }
        
        return width
    }
}

// MARK: -

extension BodyStatsPickerView: UIPickerViewDataSource, UIPickerViewDelegate {

    // MARK: - UIPickerViewDataSource Methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return componentCount()
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return rowCountInComponent(component: component)
    }
    
    // MARK: - UIPickerViewDelegate Methods

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 35.0
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return columnWidth(component: component)
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel: UILabel

        if let label = view as? UILabel {
            pickerLabel = label
        } else {
            pickerLabel = UILabel()
        }
        
        pickerLabel.attributedText = attributedTitleString(row: row, component: component)
        pickerLabel.textAlignment = .center
        
        switch pickerType {
        case .weight:
            pickerLabel.textAlignment = (component == 0) ? .right : .center
            break
        case .height:

            if seletedUnit == .us {
                pickerLabel.textAlignment = (component == 0 || component == 2) ? .right : .center

            } else {
                pickerLabel.textAlignment = (component == 0) ? .right : .center
            }

            break
        default:
            break
        }

        return pickerLabel
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

    }
}

