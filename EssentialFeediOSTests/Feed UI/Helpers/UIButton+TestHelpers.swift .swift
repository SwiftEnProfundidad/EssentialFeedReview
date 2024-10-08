//
//  UIButton+TestHelpers.swift .swift
//  EssentialFeediOSTests
//
//  Created by Juan Carlos merlos albarracin on 17/9/24.
//

import UIKit

extension UIButton {
    func simulateTap() {
        for target in allTargets {
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
