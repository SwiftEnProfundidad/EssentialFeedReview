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
  @IBOutlet private var view: UIRefreshControl?
  
  internal var delegate: FeedRefreshViewControllerDelegate? = nil
  
  @IBAction func refresh() {
    delegate?.didRequestFeedRefresh()
  }
  
  func display(_ viewModel: FeedLoadingViewModel) {
    if viewModel.isLoading {
      view?.beginRefreshing()
    } else {
      view?.endRefreshing()
    }
  }
}



