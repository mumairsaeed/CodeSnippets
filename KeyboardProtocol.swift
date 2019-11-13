//
//  KeyboardProtocol.swift
//  Beeconz
//
//  Created by Umair Saeed on 13/03/2019.
//  Copyright © 2019 Umair. All rights reserved.
//

import UIKit

// MARK: -

protocol KeyboardProtocol { }

// MARK: -

extension KeyboardProtocol where Self: UIViewController {
    
    func addKeyboardShowObserver(shouldAnimate: Bool = true, completion: (() -> Void)? = nil, onShowEvent: @escaping (CGFloat) -> Void) {
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil ) { [weak self] notification in
            let userInfo = notification.userInfo! as NSDictionary
            
            if let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                var keyboardHeight = keyboardRectangle.height
                
                if let window = UIApplication.shared.keyWindow {
                    keyboardHeight -= window.safeAreaInsets.bottom
                }
                
                let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
                let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
                
                self?.view.setNeedsLayout()
                
                onShowEvent(keyboardHeight)
                
                self?.view.setNeedsUpdateConstraints()
                
                if shouldAnimate {
                    
                    UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve), animations: {
                        self?.view.layoutIfNeeded()
                    }) { _ in
                        completion?()
                    }
                    
                } else {
                    self?.view.layoutIfNeeded()
                    completion?()
                }
            }
        }
    }
    
    func addKeyboardHideObserver(shouldAnimate: Bool = true, onHideEvent: @escaping () -> Void) {
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil ) { [weak self] notification in
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
            let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
            
            self?.view.setNeedsLayout()
            onHideEvent()
            self?.view.setNeedsUpdateConstraints()
            
            if shouldAnimate {
                
                UIView.animate(
                    withDuration: duration,
                    delay: 0,
                    options: UIView.AnimationOptions(rawValue: curve),
                    animations: {
                        self?.view.layoutIfNeeded()
                    }
                )
            } else {
                self?.view.layoutIfNeeded()
            }
        }
    }
}

// MARK: - How to use

// Add in view controller to listen changes

//extension ViewController: CBKeyboardProtocol {
//    
//    func addObservers() {
//        
//        addKeyboardShowObserver { [weak self] height in
//            guard let self = self else { return }
//            self.scrollViewBottomConstraint.constant = height
//        }
//        
//        addKeyboardHideObserver { [weak self] in
//            guard let self = self else { return }
//            self.scrollViewBottomConstraint.constant = 0
//        }
//    }
//}
