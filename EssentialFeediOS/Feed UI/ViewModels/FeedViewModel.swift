//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Juan Carlos merlos albarracin on 19/9/24.
//

import EssentialFeed

final class FeedViewModel {
  private let feedLoader: FeedLoader
  
  init(feedLoader: FeedLoader) {
    self.feedLoader = feedLoader
  }
  
  var onChange: ((FeedViewModel) -> Void)?
  var onFeedLoaded: (([FeedImage]) -> Void)?
  
  var isLoading: Bool = false {
    didSet { onChange?(self) }
  }
  
  func loadFeed() {
    isLoading = true
    feedLoader.load { [weak self] result in
      if let feed = try? result.get() {
        self?.onFeedLoaded?(feed)
      } else {
        self?.isLoading = false
      }
    }
  }
}

