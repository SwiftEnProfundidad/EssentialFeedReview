//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Juan Carlos merlos albarracin on 17/9/24.
//

import UIKit

final class FeedRefreshViewController: NSObject {
  private(set) lazy var view = binded(UIRefreshControl())
  
  private let viewModel: FeedViewModel
  
  init(viewModel: FeedViewModel) {
    self.viewModel = viewModel
  }
  
  @objc func refresh() {
    viewModel.loadFeed()
  }
  
  @objc func binded(_ view: UIRefreshControl) -> UIRefreshControl {
    viewModel.onLoadingStateChange = { [weak view] isLoading in
      if isLoading {
        view?.beginRefreshing()
      } else {
        view?.endRefreshing()
      }
    }
    view.addTarget(self, action: #selector(refresh), for: .valueChanged)
    return view
  }
}



