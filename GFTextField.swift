//
//  GFTextField.swift
//  GrindFitness
//
//  Created by Umair on 02/12/2018.
//  Copyright © 2018 Citrusbits. All rights reserved.
//

import UIKit

// MARK: -

enum GFTextFieldStatus: Int {
    case normal = 0
    case filled
    case error
}

enum GFTextFieldType: Int {
    case simple = 0
    case password
    case selectable
}

// MARK: -

@IBDesignable class GFTextField: UITextField {

    // MARK: - Constants and Properties
    
    fileprivate let characterSpacing: CGFloat = 0.5
    fileprivate let showButton: UIButton = UIButton(type: .custom)
    
    @IBInspectable var currentStatusVaue: Int = 0 {
        
        didSet {
            let value = currentStatusVaue % 3
            
            currentStatus = GFTextFieldStatus(rawValue: value) ?? .normal
        }
    }
    
    var currentStatus = GFTextFieldStatus.normal {
        
        didSet {
            updateFieldStyle()
        }
    }
    
    @IBInspectable var fieldTypeVaue: Int = 0 {
        
        didSet {
            let value = fieldTypeVaue % 3
            fieldType = GFTextFieldType(rawValue: value) ?? .simple
        }
    }
    
    var fieldType = GFTextFieldType.simple {
        
        didSet {
            updateFieldViews()
        }
    }
    
    override var placeholder: String? {
        
        didSet{
            
            if let aText = placeholder, aText.count > 0 {

                let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
                                  NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                                  NSAttributedString.Key.kern: characterSpacing] as [NSAttributedString.Key : Any]
            
                 attributedPlaceholder = NSAttributedString(string: aText, attributes: attributes)
            }
        }
    }
    
    override var isSecureTextEntry: Bool {
        
        didSet {
            
            if fieldType == .password {
                updateShowButtonText()
            }
        }
    }
    
    override var text: String? {
        
        didSet{
            textChanged(sender: self)
        }
    }

    // MARK: - Init & Override methods
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

    }
    
    override func prepareForInterfaceBuilder() {
        updateFieldStyle()
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        
        if fieldType == .selectable {
            return .zero
        }
        
        return super.caretRect(for: position)
    }
    
    // MARK: - Private methods
    
    fileprivate func setup() {
        borderStyle = UITextField.BorderStyle.none
        
        layer.masksToBounds = true
        layer.cornerRadius = 10
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15.0, height: bounds.size.height))
        leftView = paddingView
        leftViewMode = UITextField.ViewMode.always
        
        defaultTextAttributes.updateValue(characterSpacing, forKey: NSAttributedString.Key.kern)
        addTarget(self, action: #selector(textChanged(sender:)), for: .editingChanged)
        
        showButton.frame = CGRect(x: 0, y: 0, width: 60, height: 30)
        showButton.addTarget(self, action: #selector(showButtonTapped), for: .touchUpInside)
        
        updateShowButtonText()
        updateFieldStyle()
        updateFieldViews()
    }
    
    fileprivate func updateFieldStyle() {
        var borderColor = UIColor.gray
        var borderWidth: CGFloat = 1.0
        
        switch currentStatus {
        case .normal:
            borderColor = UIColor.gray
            borderWidth = 1.25
            break
        case .filled:
            borderColor = UIColor.blue
            borderWidth = 1.0
            break
        case .error:
            borderColor = UIColor.red
            borderWidth = 1.25
            break
        }
        
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        textColor = UIColor.black
        font = UIFont.systemFont(ofSize: 16.0)
    }
    
    fileprivate func updateShowButtonText() {
        let title = isSecureTextEntry ? NSLocalizedString("SHOW", comment: "") : NSLocalizedString("HIDE", comment: "")
        
        let attributedString = NSMutableAttributedString(string: title)
        
        let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 13.0),
                          NSAttributedString.Key.foregroundColor: UIColor.black,
                          NSAttributedString.Key.kern: 0.46] as [NSAttributedString.Key : Any]
        
        attributedString.addAttributes(attributes, range: NSRange(location: 0, length: title.count))

        showButton.setAttributedTitle(attributedString, for: .normal)
        showButton.setAttributedTitle(attributedString, for: .disabled)
    }
    
    fileprivate func updateFieldViews() {
        rightViewMode = UITextField.ViewMode.never
        rightView = nil
        
        switch fieldType {
        case .password:
            rightViewMode = UITextField.ViewMode.always
            rightView = showButton
            break
        case .selectable:
            rightViewMode = UITextField.ViewMode.always
            break
        default:
            break
        }
    }
    
    @objc fileprivate func showButtonTapped() {
        isSecureTextEntry = !isSecureTextEntry
        
        if let existingText = text, isSecureTextEntry {
            /* When toggling to secure text, all text will be purged if the user
             continues typing unless we intervene. This is prevented by first
             deleting the existing text and then recovering the original text. */
            deleteBackward()
            
            if let textRange = textRange(from: beginningOfDocument, to: endOfDocument) {
                replace(textRange, withText: existingText)
            }
        }
        
        /* Reset the selected text range since the cursor can end up in the wrong
         position after a toggle because the text might vary in width */
        if let existingSelectedTextRange = selectedTextRange {
            selectedTextRange = nil
            selectedTextRange = existingSelectedTextRange
        }
    }
    
    @objc fileprivate func textChanged(sender: Any) {
        
        if let aText = text, aText.count > 0 {
            currentStatus = .filled
            
        } else {
            currentStatus = .normal
        }
    }
}
