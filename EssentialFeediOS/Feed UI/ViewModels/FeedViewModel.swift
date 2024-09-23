//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Juan Carlos merlos albarracin on 19/9/24.
//

import EssentialFeed

final class FeedViewModel {
  typealias Observer<T> = (T) -> Void
  
  private let feedLoader: FeedLoader
  
  init(feedLoader: FeedLoader) {
    self.feedLoader = feedLoader
  }
  
  var onLoadingStateChange: Observer<Bool>?
  var onFeedLoaded: Observer<[FeedImage]>?
  
  func loadFeed() {
    onLoadingStateChange?(true)
    feedLoader.load { [weak self] result in
      if let feed = try? result.get() {
        self?.onFeedLoaded?(feed)
      } else {
        self?.onLoadingStateChange?(false)
      }
    }
  }
}

