//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Juan Carlos merlos albarracin on 17/9/24.
//

import UIKit

final class FeedRefreshViewController: NSObject, FeedLoadingView {
  private(set) lazy var view = binded(UIRefreshControl())
  
  private let loadFeed: () -> Void
  
  init(loadFeed: @escaping () -> Void) {
    self.loadFeed = loadFeed
  }
  
  @objc func refresh() {
    loadFeed()
  }
  
  func display(_ viewModel: FeedLoadingViewModel) {
    if viewModel.isLoading {
      view.beginRefreshing()
    } else {
      view.endRefreshing()
    }
  }
  
  @objc func binded(_ view: UIRefreshControl) -> UIRefreshControl {
    view.addTarget(self, action: #selector(refresh), for: .valueChanged)
    return view
  }
}



