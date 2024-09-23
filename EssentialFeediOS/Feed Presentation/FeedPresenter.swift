//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Juan Carlos merlos albarracin on 23/9/24.
//

import Foundation
import EssentialFeed

struct FeedLoadingViewModel {
  let isLoading: Bool
}

protocol FeedLoadingView {
  func display(_ viewModel: FeedLoadingViewModel)
}

struct FeedViewModel {
  let feed: [FeedImage]
}

protocol FeedView {
  func display(_ viewModel: FeedViewModel)
}

final class FeedPresenter {
  private let feedLoader: FeedLoader
  
  init(feedLoader: FeedLoader) {
    self.feedLoader = feedLoader
  }
  
  var feedView: FeedView?
  var loadingView: FeedLoadingView?
  
  func loadFeed() {
    loadingView?.display(FeedLoadingViewModel(isLoading: true))
    feedLoader.load { [weak self] result in
      if let feed = try? result.get() {
        self?.feedView?.display(FeedViewModel(feed: feed))
      } else {
        self?.loadingView?.display(FeedLoadingViewModel(isLoading: false))
      }
    }
  }
}
