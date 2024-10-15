//
//  UIRefreshControl+TestHelpers.swift .swift
//  EssentialFeediOSTests
//
//  Created by Juan Carlos merlos albarracin on 17/9/24.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        for target in allTargets {
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
