//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Juan Carlos merlos albarracin on 18/9/24.
//

import Foundation
import EssentialFeed

public final class FeedUIComposer {
  private init() {}
  
  public static func feedComposeWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
    let feedViewModel = FeedViewModel(feedLoader: feedLoader)
    let refreshController = FeedRefreshViewController(viewModel: feedViewModel)
    let feedController = FeedViewController(refreshController: refreshController)
    
    feedViewModel.onFeedLoaded = adapterFeedToCellControllers(forwardingTo: feedController, loader: imageLoader)
    
    return feedController
  }
  
  // [FeedImage] --> Adapter --> [FeedImageCellController]
  private static func adapterFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
    return { [weak controller] news in
      controller?.tableModel = news.map { model in
        FeedImageCellController(model: model, imageLoader: loader)
      }
    }
  }
  
}
