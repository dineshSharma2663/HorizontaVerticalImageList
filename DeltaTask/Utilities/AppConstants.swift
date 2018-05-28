//
//  AppConstants.swift
//  DeltaTask
//
//  Created by Dinesh Kumar 16 on 5/29/18.
//  Copyright © 2018 Dinesh Kumar. All rights reserved.
//

import UIKit

struct ScreenSize{
    static let SCREEN_WIDTH = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType{
    static let IS_IPHONE_4_OR_LESS =  UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5 = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6 = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPHONE_X = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 812.0
}


struct APP_CONSTANT {
    static let dismissRefreshAfter  = 0.5
    static let STATUS_BAR_MESSAGE_DISMISS_TIME = 3.0
}


extension UIColor {
    static var successColor: UIColor  { return UIColor(red: 11/255.0, green: 148/255.0, blue: 68/255.0, alpha: 1.0) }
    static var errorColor: UIColor  { return UIColor(red: 232/255.0, green: 98/255.0, blue: 109/255.0, alpha: 1.0) }
}
