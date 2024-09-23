//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Juan Carlos merlos albarracin on 17/9/24.
//

import UIKit

final class FeedRefreshViewController: NSObject, FeedLoadingView {
  private(set) lazy var view = binded(UIRefreshControl())
  
  private let presenter: FeedPresenter
  
  init(presenter: FeedPresenter) {
    self.presenter = presenter
  }
  
  @objc func refresh() {
    presenter.loadFeed()
  }
  
  func display(isLoading: Bool) {
    if isLoading {
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



