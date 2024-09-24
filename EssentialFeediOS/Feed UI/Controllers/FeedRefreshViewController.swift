//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Juan Carlos merlos albarracin on 17/9/24.
//

import UIKit

protocol FeedRefreshViewControllerDelegate {
  func didRequestFeedRefresh()
}

final class FeedRefreshViewController: NSObject, FeedLoadingView {
  private(set) lazy var view = binded(UIRefreshControl())
  
  private let delegate: FeedRefreshViewControllerDelegate
  
  init(delegate: FeedRefreshViewControllerDelegate) {
    self.delegate = delegate
  }
  
  @objc func refresh() {
    delegate.didRequestFeedRefresh()
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



