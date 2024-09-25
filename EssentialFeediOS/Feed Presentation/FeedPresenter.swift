//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Juan Carlos merlos albarracin on 23/9/24.
//

import Foundation
import EssentialFeed

protocol FeedLoadingView {
  func display(_ viewModel: FeedLoadingViewModel)
}

protocol FeedView {
  func display(_ viewModel: FeedViewModel)
}

final class FeedPresenter {
  var feedView: FeedView
  var loadingView: FeedLoadingView
  
  static var title: String {
    return NSLocalizedString("FEED_VIEW_TITLE", tableName: "Feed", bundle: Bundle(for: Self.self), comment: "Title for the feed view")
  }
  
  init(feedView: FeedView, loadingView: FeedLoadingView) {
    self.feedView = feedView
    self.loadingView = loadingView
  }
  
  func didStartLoadingFeed() {
    loadingView.display(FeedLoadingViewModel(isLoading: true))
  }
  
  func didFinishLoadingFeed(with feed: [FeedImage]) {
    feedView.display(FeedViewModel(feed: feed))
    loadingView.display(FeedLoadingViewModel(isLoading: false))
  }
  
  func didFinishLoadingFeed(with error: Error) {
    loadingView.display(FeedLoadingViewModel(isLoading: false))
  }
}
