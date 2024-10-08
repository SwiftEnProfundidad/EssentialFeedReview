//
//  FakeRefreshControl+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Juan Carlos merlos albarracin on 17/9/24.
//

import UIKit

class FakeRefreshControl: UIRefreshControl {
    private var _isRefreshing: Bool = false

    override var isRefreshing: Bool { _isRefreshing }

    override func beginRefreshing() {
        _isRefreshing = true
    }

    override func endRefreshing() {
        _isRefreshing = false
    }
}
