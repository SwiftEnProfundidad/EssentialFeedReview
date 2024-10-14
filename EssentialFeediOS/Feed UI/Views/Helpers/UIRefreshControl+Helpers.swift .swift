//
//  UIRefreshControl+Helpers.swift .swift
//  EssentialFeediOS
//
//  Created by Juan Carlos merlos albarracin on 14/10/24.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
