//
//  Utilities.swift
//  DeltaTask
//
//  Created by Dinesh Kumar on 27/05/18.
//  Copyright © 2018 Dinesh Kumar. All rights reserved.
//

import UIKit

extension UIScreen {
    func isPortrait() -> Bool {
        return UIScreen.main.bounds.width / UIScreen.main.bounds.height < 1 ? true : false
    }
}

protocol ReusableView: class {
    static var defaultReuseIdentifier: String { get }
}

extension ReusableView where Self: UIView {
    static var defaultReuseIdentifier: String {
        return String(describing: self)
    }
}


protocol NibLoadableView: class {
    static var nibName: String { get }
}

extension NibLoadableView where Self: UIView {
    static var nibName: String {
        return String(describing: self)
    }
}

