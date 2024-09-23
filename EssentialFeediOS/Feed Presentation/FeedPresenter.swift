//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Juan Carlos merlos albarracin on 23/9/24.
//

import Foundation
import EssentialFeed

protocol FeedLoadingView {
  func display(isLoading: Bool)
}

protocol FeedView {
  func display(feed: [FeedImage])
}

final class FeedPresenter {
  private let feedLoader: FeedLoader
  
  init(feedLoader: FeedLoader) {
    self.feedLoader = feedLoader
  }
  
  var feedView: FeedView?
  var loadingView: FeedLoadingView?
  
  func loadFeed() {
    loadingView?.display(isLoading: true)
    feedLoader.load { [weak self] result in
      if let feed = try? result.get() {
        self?.feedView?.display(feed: feed)
      } else {
        self?.loadingView?.display(isLoading: false)
      }
    }
  }
}
