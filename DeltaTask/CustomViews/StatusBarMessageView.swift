//
//  StatusBarMessageView.swift
//  DeltaTask
//
//  Created by Dinesh Kumar 16 on 5/27/18.
//  Copyright © 2018 Dinesh Kumar. All rights reserved.
//

import UIKit
import CoreFoundation
import Foundation

enum StatusBarStyle {
    case error
    case success
}

class StatusBarErrorMessage :NSObject {
    
    var reachability:Reachability?
    static let sharedInstance = StatusBarErrorMessage()
    var statusBarLabel : UILabel?

    /// Add Network Notifier To track Network Connection Changed
    func addNetWorkNotifier() {
        if reachability == nil {
            reachability = Reachability.init()
            try? reachability?.startNotifier()
            NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name:ReachabilityChangedNotification, object: nil)
            reachabilityChanged()
            NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        }
        // For first time app launch, we have checked internet status
    }
    
    @objc func reachabilityChanged() {
        if !(reachability?.isReachable)!{
            print("disconnected")
            let dismissTime = DeviceType.IS_IPHONE_X || !UIScreen.main.isPortrait() ? APP_CONSTANT.STATUS_BAR_MESSAGE_DISMISS_TIME : nil
            showHideStatusBar(message: "You are offline", dismissAfter: dismissTime, style: .error)
        }else {
            print("connected")
            showHideStatusBar(message: "You are online", dismissAfter: APP_CONSTANT.STATUS_BAR_MESSAGE_DISMISS_TIME, style: .success)
        }
    }
    
    @objc func orientationChanged() {
        DispatchQueue.main.async {
            self.statusBarLabel?.frame = CGRect(x:  self.statusBarLabel?.frame.origin.x ?? 0, y:  self.statusBarLabel?.frame.origin.y ?? -20, width: UIScreen.main.bounds.width, height: 20)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + APP_CONSTANT.STATUS_BAR_MESSAGE_DISMISS_TIME, execute: {
            self.dismissStatusBarView()
        })
    }

    
    /// Dismiss Status Bar Message View
    func dismissStatusBarView() {
        
        UIView.animate(withDuration: 0.5, animations: {
            self.statusBarLabel?.transform = CGAffineTransform.identity
        }) { (finished) in
            self.statusBarLabel?.isHidden = true
        }
    }
    
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - message: <#message description#>
    ///   - dismissAfter: <#dismissAfter description#>
    ///   - style: <#style description#>
    func showHideStatusBar(message:String,dismissAfter:TimeInterval?,style: StatusBarStyle) {
        DispatchQueue.main.async {
            if self.statusBarLabel == nil {
                self.statusBarLabel = UILabel()
                self.statusBarLabel?.frame = CGRect(x: 0, y: -20, width: UIScreen.main.bounds.width, height: 20)
                self.statusBarLabel?.font = UIFont(name: "Avenir-Book", size: 13.5)
                self.statusBarLabel?.textAlignment = .center
                self.statusBarLabel?.textColor = UIColor.white
                if let statusBarWindow = UIApplication.shared.value(forKey: "statusBarWindow") as? UIWindow {
                    statusBarWindow.addSubview(self.statusBarLabel!)
                }
            }
            
            self.statusBarLabel?.isHidden = false
            self.statusBarLabel?.text = message
            self.statusBarLabel?.frame = CGRect(x: self.statusBarLabel?.frame.origin.x ?? 0, y: self.statusBarLabel?.frame.origin.y ?? -20, width: UIScreen.main.bounds.width, height: 20)
            
            let barHeight : CGFloat = DeviceType.IS_IPHONE_X ? 53 : 20
            
            UIView.animate(withDuration: 0.5) {
                self.statusBarLabel?.transform = CGAffineTransform(translationX: 0, y: barHeight)
            }

            switch style {
            case StatusBarStyle.error:
                self.statusBarLabel?.backgroundColor = UIColor.errorColor
            default:
                self.statusBarLabel?.backgroundColor = UIColor.successColor
            }
            if dismissAfter != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + dismissAfter!, execute: {
                    if !((self.reachability?.isReachable) ?? true) && !DeviceType.IS_IPHONE_X {
                        print("disconnected")
                        let dismissTime = DeviceType.IS_IPHONE_X ? APP_CONSTANT.STATUS_BAR_MESSAGE_DISMISS_TIME : nil
                        self.showHideStatusBar(message: "You are offline", dismissAfter: dismissTime, style: .error)
                    }else{
                        self.dismissStatusBarView()
                    }
                })
            }
        }
    }
}

