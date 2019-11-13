//
//  AppEventProtocol
//  FullyRaw
//
//  Created by Umair Saeed  on 26/10/2018.
//  Copyright © 2018 Umair. All rights reserved.
//

import Foundation
import UIKit

// MARK: -

@objc enum AppDelegateEvent: Int, CaseIterable {
    case didBecomeActive = 0, willEnterForeground, didEnterBackground, windowBecomeVisible, windowBecomeHidden, willResignActive
    
    var notificationSystemName: NSNotification.Name {
        switch self {
        case .didBecomeActive: return UIApplication.didBecomeActiveNotification
        case .willEnterForeground: return UIApplication.willEnterForegroundNotification
        case .didEnterBackground: return UIApplication.didEnterBackgroundNotification
        case .windowBecomeHidden: return UIWindow.didBecomeHiddenNotification
        case .windowBecomeVisible: return UIWindow.didBecomeVisibleNotification
        case .willResignActive: return UIApplication.willResignActiveNotification
        }
    }
}

// MARK: -

protocol AppEventProtocol {
    func onAppStateChange(_ state: AppDelegateEvent)
}

// MARK: -

extension AppEventProtocol where Self: UIViewController {
   
    func configureAppEvents(for notification_types: [AppDelegateEvent]) {
        
        notification_types.forEach { (anEventType) in
            
            NotificationCenter.default.addObserver(forName: anEventType.notificationSystemName, object: nil, queue: nil) { [weak self] (notification) in
                self?.onAppStateChange(anEventType)
            }
        }
    }
}

// MARK: - How to use

// Add following in viewDidLoad() method
// configureAppEvents(for: [.didBecomeActive, .willResignActive])

// Add in view controller to listen changes
//extension ViewController: AppEventProtocol {
//
//    func onAppStateChange(_ state: AppDelegateEvent) {
//
//        switch state {
//
//        case .willResignActive:
//            print("willResignActive")
//
//        case .didBecomeActive:
//            print("didBecomeActive")
//
//        default:
//            break
//        }
//    }
//}
